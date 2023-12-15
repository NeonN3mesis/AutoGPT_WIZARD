#!/bin/bash

# Function to verify the success of the last command executed
verify_success() {
    if [ $? -ne 0 ]; then
        echo "An error occurred. Exiting..."
        exit 1
    fi
}

echo "Starting setup process..."

# Update and upgrade system
sudo apt update && sudo apt upgrade -y
verify_success

# Install necessary dependencies
sudo apt install apt-transport-https ca-certificates curl software-properties-common git python3 python3-pip -y
verify_success

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
verify_success
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
verify_success
sudo apt update
sudo apt install docker-ce -y
verify_success
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
verify_success

# Install Poetry and update PATH immediately for current session
curl -sSL https://install.python-poetry.org | python3 -
verify_success
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"

# Clone and set up AutoGPT
git clone https://github.com/Significant-Gravitas/AutoGPT.git
verify_success
cd AutoGPT/autogpts/autogpt
./setup
verify_success

# Prompt for OpenAI API key and update .env file
echo "Enter your OpenAI API key:"
read -r openai_api_key
sed -i "s/your-openai-api-key/${openai_api_key}/" .env.template
mv .env.template .env
verify_success

# Navigate to AutoGPT directory and run AutoGPT serve command
cd AutoGPT/autogpts/autogpt
./autogpt.sh serve

echo "AutoGPT server is running."
