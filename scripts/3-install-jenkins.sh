#!/bin/bash

set -e  # Exit immediately if a command fails

echo "=============================="
echo " Step 1: Update system & Java "
echo "=============================="

sudo apt update -y
sudo apt install -y fontconfig openjdk-21-jre

echo "Java version:"
java -version

echo "=================================="
echo " Step 2: Add Jenkins repository  "
echo "=================================="

# Create keyrings directory if it does not exist
sudo mkdir -p /etc/apt/keyrings

# Download Jenkins GPG key
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add Jenkins repository
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package list and install Jenkins
sudo apt update -y
sudo apt install -y jenkins

echo "=================================="
echo " Step 3: Enable & Start Jenkins  "
echo "=================================="

sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "=================================="
echo " Jenkins installation completed "
echo "=================================="

