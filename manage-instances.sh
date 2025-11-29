#!/bin/bash

#created by rkroeger - 2025-11-29

#you MUST change the AWS_PROFILE value first

#init configuration
APP_PATH="$HOME/manage-instances-aws"
AWS_PROFILE=mvp

if [ ! -d "APP_PATH" ]; then
  # Cria o diretório
  mkdir -p "$APP_PATH/keys"
fi

show_instances(){
    aws ec2 describe-instances \
            --query 'Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Name:Tags[?Key==`Name`]|[0].Value, State:State.Name}' \
            --filters "Name=tag:app,Values=manageinstances" \
            --profile $AWS_PROFILE\
            --output table
}

create_instance(){
    #get intances information
    read -p  "Instance Name: " instance_name
    read -p  "Instance Type[t2.micro]: " instance_type

    #collect AMI ID from ubuntu
    ami=$(aws ssm get-parameter \
    --name "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id" \
    --query "Parameter.Value" \
    --output text \
    --profile $AWS_PROFILE)

    if [ $? -ne 0 ]; then
    echo "Error - Get AMI Value"
    return 1
    fi
    
    #create a new key pair
    aws ec2 create-key-pair --key-name $instance_name --query 'KeyMaterial' --output text --profile mvp > $APP_PATH/keys/"$instance_name".pem
    if [ $? -ne 0 ]; then
    echo "Error - Create key Pair"
    return 2
    fi

    chmod 400 $APP_PATH/keys/"$instance_name".pem

    #Tag configuration and create the new instance
    tags="ResourceType=instance,Tags=[{Key=Name,Value=$instance_name},{Key=app,Value=manageinstances}]"
    aws ec2 run-instances \
    --image-id $ami \
    --count 1 \
    --instance-type $instance_type \
    --key-name $instance_name \
    --associate-public-ip-address \
    --user-data file://cloud-init.txt \
    --tag-specifications $tags \
    --profile $AWS_PROFILE
    if [ $? -ne 0 ]; then
     echo "Error - Create key Pair"
     return 2
    fi
}

delete_instance(){
    #get the intance name from shell and delete de instance.
    #the script get te instance id by tag Name
    read -p  "Instance Name: " instance_name
    instace_id=$(aws ec2 describe-instances \
            --query 'Reservations[].Instances[].InstanceId' \
            --filters "Name=tag:app,Values=manageinstances" "Name=tag:Name,Values=$instance_name" \
            --profile $AWS_PROFILE \
            --output text)
    if [ $? -ne 0 ]; then
    echo "Error - get instance id"
    return 1
    fi
    
    #remove the instance
    echo Removing instance
    aws ec2 terminate-instances --instance-ids $instace_id --profile $AWS_PROFILE
    
    if [ $? -ne 0 ]; then
    echo "Error - faill to remove the instance"
    return 1
    fi    
    
    #remove the key pair
    sleep 5
    echo Removing Key Pair
    aws ec2 delete-key-pair --key-name $instance_name  --profile $AWS_PROFILE

    if [ $? -ne 0 ]; then
    echo "Error - faill to remove the key pair"
    return 1
    fi
    
    rm -f $APP_PATH/keys/$instance_name

}

connect_instance(){
    #get the instance name to connect on the instance
    #the describe-instaces will get the external dns name
    read -p  "Instance Name: " instance_name
    external_dns=$(aws ec2 describe-instances \
            --query 'Reservations[].Instances[].NetworkInterfaces[].Association[].PublicDnsName' \
            --filters "Name=tag:app,Values=manageinstances" "Name=tag:Name,Values=$instance_name" \
            --profile $AWS_PROFILE \
            --output text)
    if [ $? -ne 0 ]; then
    echo "Error - faill to get external dns"
    return 1
    fi

    #connect on ssh
    ssh -i "$APP_PATH"/keys/$instance_name.pem ubuntu@"$external_dns"
    if [ $? -ne 0 ]; then
    echo "Error - faill to connect instance"
    return 1
    fi
}

# Menu function
menu() {
    while true; do
        echo "-----------------------------"
        echo "AWS Manage Instances"
        echo "1. Show Instances"
        echo "2. Create Instance"
        echo "3. Delete Instance"
        echo "4. Connect Instance"
        echo "X. Exit"
        echo "-----------------------------"
        echo "Enter your choice:"
        read choice

        case $choice in
            1) show_instances ;;
            2) create_instance ;;
            3) delete_instance ;;
            4) connect_instance ;;
            x|X) echo "Exiting..."; break ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

#run main menu
menu
