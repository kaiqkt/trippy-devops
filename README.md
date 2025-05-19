Docker Compose - Comandos Úteis

Visualizar Containers
----------------------
docker ps
# Lista todos os containers em execução.

docker ps -a
# Lista todos os containers (inclusive os parados).

----------------------------------------

Scale Up/Down Containers
-------------------------
docker compose up --scale nome-do-servico=N -d
# Escala o número de instâncias do serviço.

Exemplo:
docker compose up --scale kt-auth-api=3 -d

----------------------------------------

Atualizar um Container Sem Alterar os Outros
---------------------------------------------
1. Atualizar a imagem local (se necessário):
docker pull nome-da-imagem:tag

2. Parar e remover apenas o container que deseja atualizar:
docker compose stop nome-do-servico
docker compose rm -f nome-do-servico

3. Subir novamente apenas aquele container:
docker compose up -d nome-do-servico

----------------------------------------


Definir healthchecker no nginx para caso tenha erro utilizar tapume.
Como gerenciar meus containers:
    - Rede
    - Recursos etc
