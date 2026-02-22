sudo apt update -y && sudo apt upgrade -y
# 1. Download the Linux binary (latest version)
wget https://downloads.mongodb.com/compass/mongosh-2.1.1-linux-x64.tgz

# 2. Extract the file
tar -zxvf mongosh-2.1.1-linux-x64.tgz

# 3. Move the binary to your path so you can run it globally
sudo cp mongosh-2.1.1-linux-x64/bin/mongosh /usr/local/bin/
sudo cp mongosh-2.1.1-linux-x64/bin/mongosh_crypt_v1.so /usr/local/lib/ 2>/dev/null || true


