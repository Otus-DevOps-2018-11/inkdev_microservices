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

# Домашнее задание №15(docker-2)
Полезные команды
```
docker-machine create <имя> Создание хоста для докер-демона с указанным образом в провайдере(в GCP)
eval $(docker-machine env <имя>) Переключение между контейнерами
eval $(docker-machine env --unset) Переключение на локальный докер
docker-machine rm <имя> Удаление
docker build -t reddit:latest . #Сборка образа. Точка в конце-путь до docker-контекста
```


Исследованы команды
```
docker run --rm -ti tehbilly/htop
```
В данном случае видим только один запущенный процесс внутри контейнера, процессы хостовой машины не наблюдаем

```
docker run --rm --pid host -ti tehbilly/htop
```
В этом случае внутри контейнера будем видеть все процессы, запущенные на хостовой машине 

## Docker-hub
```
docker run --name reddit -d --network=host reddit:latest #Запуск контейнера
```
Регистрация на https://hub.docker.com/
Аутентификация на docker-hub
```
$ docker login
Login with your Docker ID to push and pull images from Docker Hub.
If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: your-login
Password:
Login Succeeded
```

Загрузка образа на docker hub
```
$ docker tag reddit:latest <your-login>/otus-reddit:1.0
$ docker push <your-login>/otus-reddit:1.0
The push refers to a repository [docker.io/<your-login>/otus-reddit]
c6e5100de1e0: Pushed
...
a2022691bf95: Pushed
1.0: digest:
sha256:77c6070400a5b04f8db3f7c129a2c16084c2fcf186aa6b436c8d6f57e0014378 size:
3448
```
Запсукаем с другой машины и проверяем работу контейнера
```
docker run --name reddit -d -p 9292:9292 <your-login>/otus-reddit:1.0
```
Дополнительная работа с контейнером
```
docker logs reddit -f #логи
docker exec -it reddit bash #зайти в контейнер
 ps aux 
 killall5 1
docker start reddit стартуем заново
docker stop reddit && docker rm reddit установить и удалить
docker inspect <your-login>/otus-reddit:1.0 подробная инфа об образе
docker inspect <your-login>/otus-reddit:1.0 -f '{{.ContainerConfig.Cmd}}' вывести определенный фрагмент
docker run --name reddit -d -p 9292:9292 <your-login>/otus-reddit:1.0 запустить приложение
```
