#!/bin/bash
echo "Instalador By miguel18383 dockerhub=https://hub.docker.com/r/miguel18383/github-minecraft-server github=https://github.com/migelitozapata"
echo "Bienvenido al configurador de por favor create una cuenta en"
echo "https://dashboard.ngrok.com"

token_valido=false
domain_valido=false

while [ "$token_valido" = false ]; do
    clear
    echo "En tu cuenta de ngrok ve donde dice youtoken preciona en copy y pegalo aqui"
    read -p "Introduce tu token ngrok " ngrok_token
    if [ -z "$ngrok_token" ]; then
        echo "Error: necesitamos tu token para que el servicio funcione sin eso no podras usar tu servidor!"
    else
        token_valido=true
    fi
done

while [ "$domain_valido" = false ]; do
    clear
    echo "En tu cuenta de ngrok ve a Domains y copia el dominio que te sale si no te sale preciona en newdomain"
    read -p "Introduce dominio: " ngrok_domain
    if [ -z "$ngrok_domain" ]; then
        echo "Error: No puedes dejar vacio el dominio es importante!"
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
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin cowsay figlet

WORKSPACES_DIR="/workspaces"
TARGET_DIR=$(ls -1 $WORKSPACES_DIR | grep -v '^\.' | head -n 1)

if [ -z "$TARGET_DIR" ]; then
  echo "No se encontró ninguna carpeta en $WORKSPACES_DIR"
  exit 1
fi

TARGET_PATH="$WORKSPACES_DIR/$TARGET_DIR/server"
mkdir -p $TARGET_PATH
cd $TARGET_PATH

#--------------------------------------------------------------------------------------------
# Configuración
PAPER_API="https://api.papermc.io/v2/projects/paper"
MC_VERSION=$(curl -s "$PAPER_API" | jq -r '.versions[-1]')
LATEST_BUILD=$(curl -s "$PAPER_API/versions/$MC_VERSION" | jq -r '.builds[-1]')
JAR_URL="$PAPER_API/versions/$MC_VERSION/builds/$LATEST_BUILD/downloads/paper-$MC_VERSION-$LATEST_BUILD.jar"
JAR_NAME="server.jar"

# Descargar el último PaperMC
if curl -o "$JAR_NAME" -L --fail "$JAR_URL"; then
    echo "Descarga completada: $JAR_NAME"
else
    echo "Error al descargar PaperMC" >&2
    exit 1
fi

# Verificar la integridad del archivo (tamaño mínimo de 5MB para evitar archivos corruptos)
FILE_SIZE=$(stat -c%s "$JAR_NAME")
MIN_SIZE=$((5 * 1024 * 1024))

if [[ $FILE_SIZE -ge $MIN_SIZE ]]; then
    echo "Verificación de integridad exitosa: Tamaño del archivo $FILE_SIZE bytes."
else
    echo "Error: Archivo posiblemente corrupto, pesa menos de 5MB." >&2
    rm -f "$JAR_NAME"
    exit 1
fi
#--------------------------------------------------------------------------------------------

if [ -f "server.jar" ]; then
    echo "PaperMC descargado"
else
    echo "Hubo un problema al descargar PaperMC"
fi

docker_command="docker run -d --name miguel18383 -e NGROK_TOKEN=$ngrok_token -e NGROK_DOMAIN=$ngrok_domain -v config:/home/minecraft/.config -v $TARGET_PATH:/home/minecraft/server miguel18383/github-minecraft-server"

eval $docker_command
clear
# Función para dibujar una animación de texto
animar_texto() {
    local texto="$1"
    for i in $(seq 1 ${#texto}); do
        echo -n "${texto:0:i}"
        sleep 0.1
        echo -ne "\r"
    done
    echo ""
}

# Dibujo en ASCII
dibujo="  
       _____
     .-'     `-.
    /           \
   |   O     O   |
   |     ^       |     Gracias por usar el instalador
   |    '-'      |    by miguel18383 github :D
    \   ___     /
     `-._____.-'
"

# Animación
echo "$dibujo"
sleep 1

animar_texto "Gracias por usar el instalador by miguel18383 github :D"
sleep 1

animar_texto "No te olvides de regalarme tu estrellita en"
sleep 1

animar_texto "https://hub.docker.com/r/miguel18383/github-minecraft-server"
sleep 1

animar_texto "Y compartir este link, gracias!"
sleep 1
