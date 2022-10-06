#!/bin/bash
#******************************************************************************
#    AWS VPC Creation Shell Script
#******************************************************************************
#
# SYNOPSIS
#    Automates the creation of a custom IPv4 VPC, having both a public and a
#    private subnet, and a Internet gateway.
#
# DESCRIPTION
#    This shell script leverages the AWS Command Line Interface (AWS CLI) to
#    automatically create a custom VPC.  The script assumes the AWS CLI is
#    installed and configured with the necessary security credentials.
#
#==============================================================================
#
# NOTES
#
#==============================================================================
#   MODIFY THE SETTINGS BELOW
#==============================================================================
#
AWS_REGION="ap-east-1"
VPC_NAME="testnetwork"
VPC_CIDR="172.50.200.0/25"
Environment_TAG="Production
SUBNET_PUBLIC1_CIDR="172.50.200.0/27"
SUBNET_PUBLIC1_AZ="ap-southeast-1a"
SUBNET_PUBLIC1_NAME="testnetwork_PUB_1"
SUBNET_PUBLIC2_CIDR="172.50.200.32/27"
SUBNET_PUBLIC2_AZ="ap-southeast-1b"
SUBNET_PUBLIC2_NAME="testnetwork_PUB_2"
SUBNET_PRIVATE1_CIDR="172.50.200.64/27"
SUBNET_PRIVATE1_AZ="ap-southeast-1a"
SUBNET_PRIVATE1_NAME="testnetwork_PRV_1"
SUBNET_PRIVATE2_CIDR="172.50.200.96/27"
SUBNET_PRIVATE2_AZ="ap-southeast-1b"
SUBNET_PRIVATE2_NAME="testnetwork_PRV_2"
CHECK_FREQUENCY=5
#
#==============================================================================
#   DO NOT MODIFY CODE BELOW
#==============================================================================
#
# Create VPC
echo "Creating VPC in preferred region..."
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --query 'Vpc.{VpcId:VpcId}' \
  --output text \
  --region $AWS_REGION)
echo "  VPC ID '$VPC_ID' CREATED in '$AWS_REGION' region."

# Add Name tag to VPC
aws ec2 create-tags \
  --resources $VPC_ID \
  --tags Key=Environment,Value=$Environment_TAG \
  --tags Key=Name,Value=$VPC_NAME \
  --region $AWS_REGION
echo "  VPC ID '$VPC_ID' NAMED as '$VPC_NAME'."

#60 Create Public1 Subnet
echo "Creating Public Subnet..."
SUBNET_PUBLIC1_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PUBLIC1_CIDR \
  --availability-zone $SUBNET_PUBLIC1_AZ \
  --query 'Subnet.{SubnetId:SubnetId}' \
  --output text \
  --region $AWS_REGION)
echo "  Subnet ID '$SUBNET_PUBLIC1_ID' CREATED in '$SUBNET_PUBLIC1_AZ'" \
  "Availability Zone."

# Add Name tag to Public1 Subnet
aws ec2 create-tags \
  --resources $SUBNET_PUBLIC1_ID \
  --tags "Key=Name,Value=$SUBNET_PUBLIC1_NAME" \
  --region $AWS_REGION
echo "  Subnet ID '$SUBNET_PUBLIC1_ID' NAMED as" \
  "'$SUBNET_PUBLIC1_NAME'."

echo "Creating Public2 Subnet..."
SUBNET_PUBLIC2_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PUBLIC2_CIDR \
  --availability-zone $SUBNET_PUBLIC2_AZ \
  --query 'Subnet.{SubnetId:SubnetId}' \
  --output text \
  --region $AWS_REGION)
echo "  Subnet ID '$SUBNET_PUBLIC2_ID' CREATED in '$SUBNET_PUBLIC2_AZ'" \
  "Availability Zone."

# Add Name tag to Public2 Subnet
aws ec2 create-tags \
  --resources $SUBNET_PUBLIC2_ID \
  --tags "Key=Name,Value=$SUBNET_PUBLIC2_NAME" \
  --region $AWS_REGION
echo "  Subnet ID '$SUBNET_PUBLIC2_ID' NAMED as" \
  "'$SUBNET_PUBLIC2_NAME'."

#99 Create Private1 Subnet
echo "Creating Private1 Subnet..."
SUBNET_PRIVATE1_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PRIVATE1_CIDR \
  --availability-zone $SUBNET_PRIVATE1_AZ \
  --query 'Subnet.{SubnetId:SubnetId}' \
  --output text \
  --region $AWS_REGION)
echo "  Subnet ID '$SUBNET_PRIVATE1_ID' CREATED in '$SUBNET_PRIVATE1_AZ'" \
  "Availability Zone."

# Add Name tag to Private1 Subnet
aws ec2 create-tags \
  --resources $SUBNET_PRIVATE1_ID \
  --tags "Key=Name,Value=$SUBNET_PRIVATE1_NAME" \
  --region $AWS_REGION
echo "  Subnet ID '$SUBNET_PRIVATE1_ID' NAMED as '$SUBNET_PRIVATE1_NAME'."

# Create Private2 Subnet
echo "Creating Private2 Subnet..."
SUBNET_PRIVATE2_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block $SUBNET_PRIVATE2_CIDR \
  --availability-zone $SUBNET_PRIVATE2_AZ \
  --query 'Subnet.{SubnetId:SubnetId}' \
  --output text \
  --region $AWS_REGION)
echo "  Subnet ID '$SUBNET_PRIVATE2_ID' CREATED in '$SUBNET_PRIVATE2_AZ'" \
  "Availability Zone."

# Add Name tag to Private2 Subnet
aws ec2 create-tags \
  --resources $SUBNET_PRIVATE2_ID \
  --tags "Key=Name,Value=$SUBNET_PRIVATE2_NAME" \
  --region $AWS_REGION
echo "  Subnet ID '$SUBNET_PRIVATE2_ID' NAMED as '$SUBNET_PRIVATE2_NAME'."

# Create Internet gateway
echo "Creating Internet Gateway..."
IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' \
  --output text \
  --region $AWS_REGION)
echo "  Internet Gateway ID '$IGW_ID' CREATED."

# Attach Internet gateway to your VPC
aws ec2 attach-internet-gateway \
  --vpc-id $VPC_ID \
  --internet-gateway-id $IGW_ID \
  --region $AWS_REGION
echo "  Internet Gateway ID '$IGW_ID' ATTACHED to VPC ID '$VPC_ID'."

# Create Route Table
echo "Creating Route Table..."
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --query 'RouteTable.{RouteTableId:RouteTableId}' \
  --output text \
  --region $AWS_REGION)
echo "  Route Table ID '$ROUTE_TABLE_ID' CREATED."

# Create route to Internet Gateway
RESULT=$(aws ec2 create-route \
  --route-table-id $ROUTE_TABLE_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID \
  --region $AWS_REGION)
echo "  Route to '0.0.0.0/0' via Internet Gateway ID '$IGW_ID' ADDED to" \
  "Route Table ID '$ROUTE_TABLE_ID'."

# Associate Public1 Subnet with Route Table
RESULT=$(aws ec2 associate-route-table  \
  --subnet-id $SUBNET_PUBLIC1_ID \
  --route-table-id $ROUTE_TABLE_ID \
  --region $AWS_REGION)
echo "  Public Subnet ID '$SUBNET_PUBLIC1_ID' ASSOCIATED with Route Table ID" \
  "'$ROUTE_TABLE_ID'."

# Associate Public2 Subnet with Route Table
RESULT=$(aws ec2 associate-route-table  \
  --subnet-id $SUBNET_PUBLIC2_ID \
  --route-table-id $ROUTE_TABLE_ID \
  --region $AWS_REGION)
echo "  Public Subnet ID '$SUBNET_PUBLIC2_ID' ASSOCIATED with Route Table ID" \
  "'$ROUTE_TABLE_ID'."

# Associate Private1 Subnet with Route Table
RESULT=$(aws ec2 associate-route-table  \
  --subnet-id $SUBNET_PRIVATE1_ID \
  --route-table-id $ROUTE_TABLE_ID \
  --region $AWS_REGION)
echo "  Private Subnet ID '$SUBNET_PRIVATE1_ID' ASSOCIATED with Route Table ID" \
  "'$ROUTE_TABLE_ID'."

# Associate Private2 Subnet with Route Table
RESULT=$(aws ec2 associate-route-table  \
  --subnet-id $SUBNET_PRIVATE2_ID \
  --route-table-id $ROUTE_TABLE_ID \
  --region $AWS_REGION)
echo "  Private Subnet ID '$SUBNET_PRIVATE2_ID' ASSOCIATED with Route Table ID" \
  "'$ROUTE_TABLE_ID'."

# Enable Auto-assign Public IP on Public1 Subnet
aws ec2 modify-subnet-attribute \
  --subnet-id $SUBNET_PUBLIC1_ID \
  --map-public-ip-on-launch \
  --region $AWS_REGION
echo "  'Auto-assign Public IP' ENABLED on Public1 Subnet ID" \
  "'$SUBNET_PUBLIC1_ID'."

# Enable Auto-assign Public IP on Public2 Subnet
aws ec2 modify-subnet-attribute \
  --subnet-id $SUBNET_PUBLIC2_ID \
  --map-public-ip-on-launch \
  --region $AWS_REGION
echo "  'Auto-assign Public IP' ENABLED on Public2 Subnet ID" \
  "'$SUBNET_PUBLIC_ID'."

echo "COMPLETED"
