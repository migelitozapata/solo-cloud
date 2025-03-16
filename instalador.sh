#!/bin/bash
echo "Bienvenido al configurador de por favor create una cuenta en https://dashboard.ngrok.com"

token_valido=false
domain_valido=false

while [ "$token_valido" = false ]; do
    read -p "Introduce tu NGROK_TOKEN: " ngrok_token
    if [ -z "$ngrok_token" ]; then
        echo "Error: No puedes dejar el NGROK_TOKEN vacío. Inténtalo de nuevo."
    else
        token_valido=true
    fi
done

while [ "$domain_valido" = false ]; do
    echo "Recuerda que el NGROK_DOMAIN tiene un formato similar a: tu-subdominio.ngrok-free.app"
    read -p "Introduce tu NGROK_DOMAIN: " ngrok_domain
    if [ -z "$ngrok_domain" ]; then
        echo "Error: No puedes dejar el NGROK_DOMAIN vacío. Inténtalo de nuevo."
    else
        domain_valido=true
    fi
done

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

WORKSPACES_DIR="/workspaces"
TARGET_DIR=$(ls -1 $WORKSPACES_DIR | grep -v '^\.' | head -n 1)

if [ -z "$TARGET_DIR" ]; then
  echo "No se encontró ninguna carpeta en $WORKSPACES_DIR"
  exit 1
fi

TARGET_PATH="$WORKSPACES_DIR/$TARGET_DIR/server"
mkdir -p $TARGET_PATH
cd $TARGET_PATH

echo "Descargando la última versión de PaperMC..."
curl -o server.jar https://api.papermc.io/v2/projects/paper/versions/latest/download

if [ -f "server.jar" ]; then
    echo "PaperMC descargado"
else
    echo "Hubo un problema al descargar PaperMC"
fi

docker_command="docker run -d --name miguel18383 -e NGROK_TOKEN=$ngrok_token -e NGROK_DOMAIN=$ngrok_domain -v config:/home/minecraft/.config -v $TARGET_PATH:/home/minecraft/server miguel18383/github-minecraft-server"

eval $docker_command

echo "Gracias por usar el instalador par github :D no te olvides de regalar tu estrellita gracias :D"

