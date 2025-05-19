#!/bin/bash

SERVICE="kt-auth-api"
NEW_IMAGE="kt-auth-api:v1.1.0"

# Função para verificar se o container está ativo
check_container_running() {
  local container_name=$1
  docker inspect --format '{{.State.Running}}' $container_name | grep -q "true"
}

# Função para esperar até que a instância esteja ativa
wait_for_instance() {
  local container_name=$1
  echo "Aguardando instância $container_name ficar ativa..."
  until check_container_running $container_name; do
    sleep 2  # Aguardar 2 segundos antes de tentar novamente
  done
  echo "Instância $container_name está ativa."
}

# Passo 1: Criar novas instâncias
echo "Criando novas instâncias com a nova versão..."
docker compose up -d --no-deps --scale $SERVICE=2 $SERVICE  # Cria 2 novas instâncias

# Passo 2: Obter os nomes das novas instâncias dinamicamente
echo "Obtendo os nomes das novas instâncias..."
NEW_INSTANCES=$(docker ps --filter "ancestor=$NEW_IMAGE" --filter "name=$SERVICE" --format '{{.Names}}')

echo "Novas instâncias criadas: $NEW_INSTANCES"

# Passo 3: Verificar se as novas instâncias estão ativas
echo "Verificando se as novas instâncias estão ativas..."
for INSTANCE in $NEW_INSTANCES; do
  wait_for_instance $INSTANCE
done

# Passo 4: Desligar gradualmente as antigas instâncias
echo "Desligando as instâncias antigas uma por vez..."
OLD_INSTANCES=$(docker ps --filter "name=$SERVICE" --format '{{.Names}}' | grep -vE "$(echo $NEW_INSTANCES | sed 's/ /|/g')")

for INSTANCE in $OLD_INSTANCES; do
  echo "Desligando a instância antiga: $INSTANCE"

  # Para a instância antiga e remove
  docker stop $INSTANCE
  docker rm $INSTANCE

  # Verifica se a instância foi removida com sucesso
  while docker ps --filter "name=$INSTANCE" --format '{{.Names}}' | grep -q $INSTANCE; do
    echo "Aguardando a remoção completa de $INSTANCE..."
    sleep 2  # Aguardar antes de tentar novamente
  done

  echo "Instância $INSTANCE removida com sucesso."
  # Espera um pouco entre as remoções para garantir estabilidade
  sleep 5
done

echo "Rolling update concluído com sucesso!"
