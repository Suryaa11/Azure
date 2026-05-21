<img width="758" height="679" alt="agw" src="https://github.com/user-attachments/assets/19d6ef48-c696-4be2-8891-6b29f96fb863" />

# Domain-Based Routing using Azure Application Gateway WAF with Private Virtual Machines and NAT Gateway

## Architecture Overview

This setup demonstrates a secure and production-style architecture in Microsoft Azure where two separate applications are hosted on private virtual machines and exposed to the internet using Azure Application Gateway WAF v2 with domain-based routing.

Both applications are deployed on separate private VMs inside the same virtual network. The VMs do not have public IP addresses. Outbound internet access is provided through a NAT Gateway, while inbound traffic is securely managed by Azure Application Gateway with WAF enabled.

------------------------------------------------------------
FINAL ARCHITECTURE
------------------------------------------------------------

<img width="758" height="679" alt="agw" src="https://github.com/user-attachments/assets/2dd85510-a527-4c66-9253-5fc6e846ea2b" />

------------------------------------------------------------
RESOURCES CREATED
------------------------------------------------------------

1. Resource Group
2. Virtual Network (VNet)
3. Application Gateway Subnet
4. VM Subnet
5. Private Virtual Machine 1
6. Private Virtual Machine 2
7. VM1 Network Security Group
8. VM2 Network Security Group
9. NAT Gateway
10. Public IP for NAT Gateway
11. Application Gateway WAF v2
12. Public IP for Application Gateway
13. WAF Policy
14. DNS Records

------------------------------------------------------------
NETWORK CONFIGURATION
------------------------------------------------------------

VNet Address Space:
10.0.0.0/16

Subnets:

1. Application Gateway Subnet
10.0.0.0/24

2. VM Subnet
10.0.1.0/24

------------------------------------------------------------
STEP 1 — CREATE RESOURCE GROUP
------------------------------------------------------------

A Resource Group was created to manage all Azure resources under a single logical container.

Region:
Central India

------------------------------------------------------------
STEP 2 — CREATE VIRTUAL NETWORK
------------------------------------------------------------

A Virtual Network was created with the following address space:

10.0.0.0/16

Two subnets were configured inside the VNet.

Application Gateway Subnet:
10.0.0.0/24

VM Subnet:
10.0.1.0/24

The Application Gateway was deployed in the Application Gateway subnet, while both private virtual machines were deployed in the VM subnet.

------------------------------------------------------------
STEP 3 — CREATE NETWORK SECURITY GROUPS
------------------------------------------------------------

Two separate Network Security Groups were created:

1. VM1-NSG
2. VM2-NSG

These NSGs were associated with the virtual machines to control inbound and outbound traffic.

Inbound Rules Configured:

Port 22  → SSH Access  
Port 80  → HTTP Traffic  
Port 443 → HTTPS Traffic

------------------------------------------------------------
STEP 4 — CREATE PRIVATE VIRTUAL MACHINES
------------------------------------------------------------

Two Ubuntu virtual machines were created inside the VM subnet.

Configuration:

Operating System : Ubuntu 22.04  
Region           : Central India  
Public IP        : None  
Network Type     : Private

Both VMs were intentionally deployed without public IP addresses for better security.

------------------------------------------------------------
STEP 5 — DEPLOY APPLICATIONS
------------------------------------------------------------

Separate applications were deployed on each VM.

VM1:
Hosted Application 1

VM2:
Hosted Application 2

Both applications run independently and are exposed using separate subdomains through Application Gateway routing rules.

------------------------------------------------------------
VM1 DEPLOYMENT SCRIPT
------------------------------------------------------------

```bash
#!/bin/bash
cd /home/surya
apt-get update -y
apt-get install nginx -y
apt-get install nodejs -y
apt-get install npm -y
apt-get install git -y

git clone https://github.com/Suryaa11/Fitness_Tracker.git

cat <<EOF > /etc/nginx/sites-available/custom
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://localhost:5000;
    }
}
EOF

ln -s /etc/nginx/sites-available/custom /etc/nginx/sites-enabled/

cd /etc/nginx/sites-enabled
rm -rf default

systemctl restart nginx

cd /home/surya/Fitness_Tracker/server

npm install -g pm2

pm2 start app.js --name "fitness-app"

pm2 save
pm2 startup
```

------------------------------------------------------------
VM2 DEPLOYMENT SCRIPT
------------------------------------------------------------

```bash
#!/bin/bash
cd /home/surya
apt-get update -y
apt-get install nginx -y
apt-get install nodejs -y
apt-get install npm -y
apt-get install git -y

git clone https://github.com/Msocial123/organic-ghee.git

cat <<EOF > /etc/nginx/sites-available/custom
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://localhost:5656;
    }
}
EOF

ln -s /etc/nginx/sites-available/custom /etc/nginx/sites-enabled/

cd /etc/nginx/sites-enabled
rm -rf default

systemctl restart nginx

cd /home/surya/organic-ghee

npm install -g pm2

pm2 start src/app.js --name "organic-app"

pm2 save
pm2 startup
```

------------------------------------------------------------
STEP 6 — CREATE NAT GATEWAY
------------------------------------------------------------

A NAT Gateway was created and associated with the VM subnet.

Purpose of NAT Gateway:

- Provides outbound internet access for private VMs
- Allows package installation and updates
- Prevents exposing VMs directly to the internet
- Provides secure outbound connectivity

A static public IP address was attached to the NAT Gateway.

------------------------------------------------------------
STEP 7 — VERIFY OUTBOUND CONNECTIVITY
------------------------------------------------------------

Outbound internet access was verified from both VMs using commands such as:

```bash
sudo apt update

curl google.com
```

The outbound requests were routed through the NAT Gateway.

------------------------------------------------------------
STEP 8 — CREATE WAF POLICY
------------------------------------------------------------

An Azure Web Application Firewall (WAF) policy was created in Prevention Mode.

Purpose of WAF:

- Protects applications from common web attacks
- Filters malicious requests
- Provides Layer 7 security
- Helps prevent OWASP vulnerabilities

------------------------------------------------------------
STEP 9 — CREATE APPLICATION GATEWAY WAF v2
------------------------------------------------------------

An Azure Application Gateway WAF v2 instance was deployed.

Features Used:

- Layer 7 Load Balancing
- Reverse Proxy
- Domain-Based Routing
- Web Application Firewall
- Autoscaling

The Application Gateway was assigned a public IP address to expose applications to the internet.

------------------------------------------------------------
STEP 10 — CONFIGURE BACKEND POOLS
------------------------------------------------------------

Two backend pools were configured inside the Application Gateway.

Backend Pool 1:
Connected to VM1 private IP

Backend Pool 2:
Connected to VM2 private IP

The Application Gateway forwards requests to the appropriate backend VM based on the requested hostname.

------------------------------------------------------------
STEP 11 — CONFIGURE DOMAIN-BASED ROUTING
------------------------------------------------------------

Two multi-site listeners and routing rules were configured.

Routing Rules:

app1.domain.com → VM1

app2.domain.com → VM2

Routing Behavior:

- Requests to app1.domain.com are forwarded to VM1
- Requests to app2.domain.com are forwarded to VM2

This setup allows multiple applications to be hosted behind a single public IP address.

------------------------------------------------------------
STEP 12 — CONFIGURE DNS
------------------------------------------------------------

DNS records were created at the domain provider.

Both subdomains point to the public IP address of the Application Gateway.

Example:

A Record → app1 → Application Gateway Public IP

A Record → app2 → Application Gateway Public IP

------------------------------------------------------------
STEP 13 — FINAL VERIFICATION
------------------------------------------------------------

After DNS propagation, both applications became accessible through their respective subdomains.

Example:

http://app1.domain.com → Application hosted on VM1

http://app2.domain.com → Application hosted on VM2

------------------------------------------------------------
SECURITY ADVANTAGES
------------------------------------------------------------

- Backend virtual machines remain private
- No public IPs attached to backend VMs
- WAF protects applications from web attacks
- Application Gateway acts as a secure entry point
- NAT Gateway handles outbound internet access securely
- Domain-based routing supports multiple applications using a single gateway

------------------------------------------------------------
CONCLUSION
------------------------------------------------------------

This architecture demonstrates a secure and scalable Azure deployment using:

- Azure Application Gateway WAF v2
- Private Virtual Machines
- NAT Gateway
- Domain-Based Routing
- Separate backend applications
- DNS-based exposure using subdomains

The setup follows a production-style deployment model where backend infrastructure remains private while applications are securely exposed through Azure Application Gateway with WAF protection.
