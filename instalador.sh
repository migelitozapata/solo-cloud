#!/bin/bash

# Actualizar el sistema
sudo apt-get update -y && sudo apt-get upgrade -y

# Instalar dependencias necesarias
sudo apt-get install -y ca-certificates curl

# Crear el directorio de keyrings
sudo install -m 0755 -d /etc/apt/keyrings

# Añadir la clave GPG oficial de Docker
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Añadir el repositorio de Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Actualizar los repositorios y instalar Docker
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Crear la carpeta 'server'
mkdir -p ~/server

# Navegar a la carpeta 'server'
cd ~/server

# Descargar la última versión de PaperMC
echo "Descargando la última versión de PaperMC..."
curl -o paperclip.jar https://api.papermc.io/v2/projects/paper/versions/latest/download

# Verificar si la descarga fue exitosa
if [ -f "paperclip.jar" ]; then
    echo "PaperMC descargado con éxito en ~/server/paperclip.jar"
else
    echo "Hubo un problema al descargar PaperMC"
fi

# Menú interactivo para configurar el comando docker
clear
echo "Bienvenido al configurador de Docker para PaperMC"

# Preguntar por el nombre del contenedor
read -p "Introduce el nombre de tu servidor Minecraft (esto se usará como --name): " server_name

# Instrucciones para obtener el NGROK_TOKEN y NGROK_DOMAIN
echo "Por favor, crea una cuenta en Ngrok y obtén tu NGROK_TOKEN y NGROK_DOMAIN."
echo "Visita https://dashboard.ngrok.com/ para crear una cuenta."
echo "Una vez que tengas tu NGROK_TOKEN, ingrésalo a continuación."

# Preguntar por el NGROK_TOKEN
read -p "Introduce tu NGROK_TOKEN: " ngrok_token

# Preguntar por el NGROK_DOMAIN
echo "Recuerda que el NGROK_DOMAIN tiene un formato similar a: tu-subdominio.ngrok-free.app"
read -p "Introduce tu NGROK_DOMAIN: " ngrok_domain

# Obtener el nombre del usuario actual (después de /workspaces/)
user_name=$(whoami)

# Construir el volumen correctamente con el nombre del usuario
volume_path="/workspaces/$user_name/solo-cloud/server:/home/minecraft/server"

# Construir el comando Docker con la información proporcionada
docker_command="docker run -d --name $server_name -e NGROK_TOKEN=$ngrok_token -e NGROK_DOMAIN=$ngrok_domain -v config:/home/minecraft/.config -v $volume_path mcply/miguel"

# Mostrar el comando final al usuario
echo "Gracias por usar el instalador par github :D no te olvides de regalar tu estrellita gracias :D"
