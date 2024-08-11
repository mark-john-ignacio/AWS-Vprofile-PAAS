#!/bin/bash

# Destroy the SQL executor
terraform destroy --target aws_instance.sql_executor -auto-approve