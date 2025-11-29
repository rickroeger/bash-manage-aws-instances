# bash-manage-aws-instances
Script on bash to create, connect and remove instances from aws

## 1. How to use
Download the manage-instances.sh file and change its permission
```
chmod +x manage-instances.sh
```
Configure the AWS profile. You must configure the accesskey and secretkey on AWS console
```
aws configure --profile test
AWS Access Key ID [None]: myaccesskey
AWS Secret Access Key [None]: mysecretkey
Default region name [None]:
Default output format [None]:
```
On the script, you must change the AWS_PROFILE varabile to your profile name
```
#init configuration
APP_PATH="$HOME/manage-instances-aws"
AWS_PROFILE=test
```

## 2. Running the script
Execute the script
```
./manage-instances.sh
```
The main menu will appear
```
./manage-instances.sh
-----------------------------
AWS Manage Instances
1. Show Instances
2. Create Instance
3. Delete Instance
4. Connect Instance
X. Exit
-----------------------------
Enter your choice:
```

Choose the option 1 to show the intances (an example), but select on menu the option that you want
```
AWS Manage Instances
1. Show Instances
2. Create Instance
3. Delete Instance
4. Connect Instance
X. Exit
-----------------------------
Enter your choice:
1
------------------------------------------------------------------------
|                           DescribeInstances                          |
+------------+-----------------------+-------------------+-------------+
|     AZ     |       Instance        |       Name        |    State    |
+------------+-----------------------+-------------------+-------------+
|  us-east-1d|  i-0cb0c867fad474000  |  SERVER003        |  running    |
|  us-east-1d|  i-0a4b76804e4075000  |  SERVER001        |  running    |
|  us-east-1d|  i-0dab3d7a320d2e000  |  SERVER002        |  running    |
+------------+-----------------------+-------------------+-------------+
```

