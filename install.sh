sudo apt install -y zsh
sudo chsh -s /usr/bin/zsh

sudo apt install -y git

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
echo 'source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh' >>~/.zshrc
echo '
setopt SHARE_HISTORY
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt HIST_EXPIRE_DUPS_FIRST' >>~/.zshrc
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
echo 'clear' >>~/.zshrc

sudo apt-get remove -y docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose;
sudo systemctl start docker
cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["https://m.docker-registry.ir"]
}
EOF
sudo systemctl restart docker

sudo apt -y install nginx

sed -i 's/80 default_server/8080 default_server/' /etc/nginx/sites-available/default

sudo service nginx stop
sudo service nginx start

docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:2.9.3


cd
mkdir npm
cd npm

echo "nginx proxy manager database config"
read -p "db Root Password: " rootpwd 
read -p "db Username: " username
read -p "db Password: " pwd
cat > docker-compose.yml <<EOF
version: '3'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: npm
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    environment:
      DB_MYSQL_HOST: "db"
      DB_MYSQL_PORT: 3306
      DB_MYSQL_USER: $username 
      DB_MYSQL_PASSWORD: $pwd 
      DB_MYSQL_NAME: "npm"
    volumes:
      - ./npm/srv/config/nginxproxymanager:/data
      - ./npm/srv/config/nginxproxymanager/letsencrypt:/etc/letsencrypt
  db:
    image: 'jc21/mariadb-aria'
    container_name: npm_db
    environment:
      MYSQL_ROOT_PASSWORD: $rootpwd 
      MYSQL_DATABASE: 'npm'
      MYSQL_USER: $username 
      MYSQL_PASSWORD: $pwd 
    volumes:
      - ./npm/srv/config/nginxproxymanager/db:/var/lib/mysql
EOF

sudo docker-compose up -d

echo "Portainer Docker Manager= http://"$server_ip":9443"
echo "---------------------------------------------------"
echo "Nginx Proxy Manager Docker= http://"$serverip":81"
echo "    Default username= admin@example.com"
echo "    Default password= changeme"

