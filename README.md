# inkdev_microservices
inkdev microservices repository

# Домашнее задание №14(docker-1)
Полезные команды
```
docker version – версии docker client и server
docker info – информация о текущем состоянии docker daemon
docker ps #список всех запущенных контейнеров
docker ps -a #список всех контейнеров
docker images #список сохраненных образов
docker run -it ubuntu:16.04 /bin/bash #Команда run создает и запускает контейнер из image
#Если не указывать флаг --rm при запуске docker run, то после остановки контейнер вместе с содержимым остается на диске
docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}" #список контейнеров в табличном виде
docker start <u_container_id> start запускает остановленный(уже созданный) контейнер\
docker attach <u_container_id> attach подсоединяет терминал к созданному контейнеру
#docker run = docker create + docker start + docker attach*
#docker create используется, когда не нужно стартовать контейнер сразу
#в большинстве случаев используется docker run

Через параметры передаются лимиты(cpu/mem/disk), ip, volumes 
-i – запускает контейнер в foreground режиме (docker attach)
-d – запускает контейнер в background режиме
-t -  создает TTY  

docker exec -it <u_container_id> bash Запускает новый процесс внутри контейнера
docker commit <u_container_id> yourname/ubuntu-tmp-file Создает image из контейнера
docker system df #Отображает сколько дискового пространства занято образами, контейнерами и volume’ами
docker rm $(docker ps -a -q) # удалит все незапущенные контейнеры
docker rmi $(docker images -q) #rmi удаляет image, если от него не зависят
запущенные контейнеры
```


