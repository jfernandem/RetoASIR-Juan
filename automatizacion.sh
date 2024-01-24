# Definir variables
NOMBRE_VPC="MiVPC"
CIDR_VPC="10.70.0.0/16"
NOMBRE_SUBRED_PUBLICA="SubredPublica"
CIDR_SUBRED_PUBLICA="10.70.1.0/24"
NOMBRE_SUBRED_PRIVADA="SubredPrivada"
CIDR_SUBRED_PRIVADA="10.70.2.0/24"
DEBIAN="ami-058bd2d568351da34"
UBUNTU="ami-0c7217cdde317cfec"
AMAZON-LINUX="ami-0a3c3a20c09d6f377"
 
# Crear VPC
vpcId=$(aws ec2 create-vpc --cidr-block $CIDR_VPC --output json | jq -r '.Vpc.VpcId')
aws ec2 create-tags --resources $vpcId --tags Key=Name,Value=$NOMBRE_VPC
 
# Crear subred pública
subnetPublicaId=$(aws ec2 create-subnet --vpc-id $vpcId --cidr-block $CIDR_SUBRED_PUBLICA --availability-zone us-east-1a --output json | jq -r '.Subnet.SubnetId')
aws ec2 create-tags --resources $subnetPublicaId --tags Key=Name,Value=$NOMBRE_SUBRED_PUBLICA
 
# Crear subred privada
subnetPrivadaId=$(aws ec2 create-subnet --vpc-id $vpcId --cidr-block $CIDR_SUBRED_PRIVADA --availability-zone us-east-1b --output json | jq -r '.Subnet.SubnetId')
aws ec2 create-tags --resources $subnetPrivadaId --tags Key=Name,Value=$NOMBRE_SUBRED_PRIVADA
 
# Crear Internet Gateway
internetGatewayId=$(aws ec2 create-internet-gateway --output json | jq -r '.InternetGateway.InternetGatewayId')
aws ec2 create-tags --resources $internetGatewayId --tags Key=Name,Value=${NOMBRE_VPC}-IG
 
# Adjuntar Internet Gateway a la VPC
aws ec2 attach-internet-gateway --vpc-id $vpcId --internet-gateway-id $internetGatewayId
 
# Crear tabla de rutas pública
routeTablePublicId=$(aws ec2 create-route-table --vpc-id $vpcId --output json | jq -r '.RouteTable.RouteTableId')
 
# Crear ruta para tráfico público
aws ec2 create-route --route-table-id $routeTablePublicId --destination-cidr-block 0.0.0.0/0 --gateway-id $internetGatewayId
 
# Asociar tabla de rutas pública a la subred pública
aws ec2 associate-route-table --subnet-id $subnetPublicaId --route-table-id $routeTablePublicId
 
#Crear Gateway NAT
allocationId=$(aws ec2 allocate-address --domain vpc --output json | jq -r '.AllocationId')
natGatewayId=$(aws ec2 create-nat-gateway --subnet-id $subnetPublicaId --allocation-id $allocationId --output json | jq -r '.NatGateway.NatGatewayId')
 
# Esperar hasta que el Nat Gateway esté disponible
echo "Esperando a que el Nat Gateway esté disponible..."
aws ec2 wait nat-gateway-available --nat-gateway-ids $natGatewayId
 
# Crear tabla de rutas privada
routeTablePrivadaId=$(aws ec2 create-route-table --vpc-id $vpcId --output json | jq -r '.RouteTable.RouteTableId')
 
# Crear ruta para tráfico privado a través del Gateway NAT
aws ec2 create-route --route-table-id $routeTablePrivadaId --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $natGatewayId
 
# Asociar tabla de rutas privada a la subred privada
aws ec2 associate-route-table --subnet-id $subnetPrivadaId --route-table-id $routeTablePrivadaId
 
