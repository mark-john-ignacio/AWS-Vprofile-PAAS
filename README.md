Notes: sql_executor and resource "aws_security_group_rule" "allow_eb_to_backend" are commented out because they cause issues if they are ran together withall the other resources

Change credential path on provider if using aws credentials to run terraform

after beanstalk is active, clone https://github.com/hkhcoder/vprofile-project.git
go to src, main, resources > application.properties and changethe credentials of 
rds
memcached
rabbitmq that will be created from this terraform that is saved on the key folder
check the aws console for the url and host and port

rabbitmq
username = "rabbit"
password = found in key folder
address = can be found in console amazon mq endpoint
example:
amqps://b-403fbcae-9d22-45fa-9a76-b103adf16703.mq.us-east-1.amazonaws.com:5671
port:5671

jdbc
username = admin
password = found in key folder
jdbc url = endpoint found in console rds
example: vprofile-rds-mysql.c9qgosauahei.us-east-1.rds.amazonaws.com
port:3306

memcached
host: in console in amazon elasticache>Memcached caches
find vprofile
example:
vprofile-elasticache-svc.grob8j.cfg.use1.cache.amazonaws.com:11211

mvn -version on terminal
mvn install

war file is in target/

Goto console elastic beanstalk, and upload and deploy war file with preferred version name

wait for it to be deployed

use beanstalk domain to cname to your domain