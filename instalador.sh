#!/bin/bash

sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get remove --purge moby-tini -y
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

user_name=$(whoami)

mkdir -p /workspaces/$(basename $(pwd))/server
cd /workspaces/$(basename $(pwd))/server

echo "Descargando la última versión de PaperMC..."
curl -o server.jar https://api.papermc.io/v2/projects/paper/versions/latest/download

if [ -f "server.jar" ]; then
    echo "PaperMC descargado"
else
    echo "Hubo un problema al descargar PaperMC"
fi

clear
echo "Bienvenido al configurador de Docker para PaperMC"
read -p "Introduce el nombre de tu servidor Minecraft (esto se usará como --name): " server_name
echo "Por favor, crea una cuenta en Ngrok y obtén tu NGROK_TOKEN y NGROK_DOMAIN."
echo "Visita https://dashboard.ngrok.com/ para crear una cuenta."
echo "Una vez que tengas tu NGROK_TOKEN, ingrésalo a continuación."
read -p "Introduce tu NGROK_TOKEN: " ngrok_token
echo "Recuerda que el NGROK_DOMAIN tiene un formato similar a: tu-subdominio.ngrok-free.app"
read -p "Introduce tu NGROK_DOMAIN: " ngrok_domain

docker_command="docker run -d --name $server_name -e NGROK_TOKEN=$ngrok_token -e NGROK_DOMAIN=$ngrok_domain -v config:/home/minecraft/.config -v /workspaces/$(basename $(pwd))/server:/home/minecraft/server miguel18383/github-minecraft-server"

eval $docker_command

ruta="/workspaces/$(basename $(pwd))/server"
echo "La carpeta se ha creado en: $ruta"

echo "Gracias por usar el instalador par github :D no te olvides de regalar tu estrellita gracias :D"

