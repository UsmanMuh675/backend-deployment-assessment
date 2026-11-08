
#!/bin/bash
set -eux

# Update system packages
dnf update -y

# Configure MongoDB repository
cat > /etc/yum.repos.d/mongodb-org-8.0.repo <<'EOF'
[mongodb-org-8.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2023/mongodb-org/8.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-8.0.asc
EOF

# Install MongoDB
dnf install -y mongodb-org

# Allow MongoDB to listen on network interfaces.
# Access remains restricted by the MongoDB security group.
sed -i 's/^  bindIp: 127.0.0.1/  bindIp: 0.0.0.0/' /etc/mongod.conf

# Start MongoDB
systemctl enable mongod
systemctl start mongod

# Verify MongoDB
systemctl status mongod --no-pager

echo "MongoDB setup completed successfully"
