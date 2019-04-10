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

### Задание со *
- В папке docker-monolith/infra создали проект, позволяющий развернуть инстансы с установленным приложением на базе docker внутри
- Опиcали поднятие инстансов с помощью Terraform, количество количество которых  задается с помощью переменной  node_count
- Описали сценарии поднятия Docker и развертывания контейнера внутри с установленным приложением reddit с помощью динамического инвентори terraform-inventory
```
TF_STATE=../terraform ansible-playbook playbooks/reddit-docker.yml
```
Поднятие Docker реализовали через роль из ansible-galaxy geerlingguy.docker
- Создали шаблон пакера с запеченным внутри Docker docker-reddit-1554813982
- Развернули указанные инстансы и плейбуки, проверили работоспособность приложения


# Домашнее задание №16(docker-3)
Полезные команды
```
docker pull mongo:latest #Скачиваем последний образ MongoDB
docker build -t inks/post:1.0 ./post-py
docker build -t inks/comment:1.0 ./comment
docker build -t inks/ui:1.0 ./ui # Сборка контейнеров
```

- Создаем три контейнера для каждого микросервиса post-py, comment, ui
Сборка ui началась не с первого шага, потому что остались предыдущие слои от сбора контейнера comment
- Проверяем с помощью линтера hadolint Dockerfile в каждой из папок
Сайт проекта 
https://github.com/hadolint/hadolint
Установка hadolint
```
docker pull hadolint/hadolint
```
Проверка Dockerfile
```
docker run --rm -i hadolint/hadolint < Dockerfile
```
Проверили все Dockerfile, исправили ошибки кроме версионирования пакетов

- Создаем docker bridge  сеть
```
docker network create reddit
docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
c9b65fe3a70b        bridge              bridge              local
872151e2863b        host                host                local
0ed4f163576f        none                null                local
f4b77fa58ff9        reddit              bridge              local
```
- Запускаем контейнеры и добавляем сетевые алиасы
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post inks/post:1.0
docker run -d --network=reddit --network-alias=comment inks/comment:1.0
docker run -d --network=reddit -p 9292:9292 inks/ui:1.0
```
- Проверяем
```
docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS                        PORTS                    NAMES
a87ea02f398c        inks/ui:1.0         "puma"                   About a minute ago   Up About a minute             0.0.0.0:9292->9292/tcp   silly_dubinsky
a00059c7c9ec        inks/comment:1.0    "puma"                   About a minute ago   Up About a minute                                      silly_matsumoto
7d9a27ef2545        inks/post:1.0       "python3 post_app.py"    About a minute ago   Up About a minute                                      hungry_curie
d1de3826414d        mongo:latest        "docker-entrypoint.s…"   About a minute ago   Up About a minute             27017/tcp                zealous_babbage
```

### Задание со * №1
- Останавливаем контейнеры
```
docker kill $(docker ps -q)
```
- Запускаем контейнеры с другими сетевыми алиасами , подерживаем взаимодействие через ENV переменные
```
docker run -d --network=reddit --network-alias=post_db_new --network-alias=comment_db_new mongo:latest \
&& docker run -d --network=reddit --network-alias=post_new --env POST_DATABASE_HOST=post_db_new inks/post:1.0 \
&& docker run -d --network=reddit --network-alias=comment_new --env COMMENT_DATABASE_HOST=comment_db_new inks/comment:1.0 \
&& docker run -d --network=reddit --env POST_SERVICE_HOST=post_new --env COMMENT_SERVICE_HOST=comment_new -p 9292:9292 inks/ui:1.0
```
- Проверяем работоспособность приложения
```
curl http://external_ip:9292
```
### Продолжение основного задания

- Улучшаем образ ui, пересобираем контейнер с помощью нового Dockerfile
- Пересобираем ui
```
docker build -t inks/ui:2.0 ./ui
```
Проверяем, образ уменьшился до 447 Мб
```
 docker images
REPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
inks/ui             2.0                 cbd3055df020        About a minute ago   447MB
inks/ui             1.0                 4e934e3b4354        4 hours ago          958MB
inks/comment        1.0                 64fd9ba575f1        14 hours ago         956MB
inks/post           1.0                 aed6599b931b        15 hours ago         206MB
```

### Задание со * №2
- Применяем Alpine для уменьшения размера образа
```
FROM alpine
RUN apk add --no-cache build-base ruby ruby-bundler ruby-dev ruby-json \
    && gem install bundler --no-ri --no-rdoc
```
Пересобираем образ 
```
docker build -t inks/ui:3.0 ./ui
```
Образ сжался до 228 Мб
```
docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
inks/ui             3.0                 9b78bf6f5ffa        2 minutes ago       228MB
inks/ui             2.0                 cbd3055df020        17 minutes ago      447MB
inks/ui             1.0                 4e934e3b4354        5 hours ago         958MB
```
- Уменьшаем образ за счет удаления ненужных библиотек и чистки кэша. Итоговый образ занимает 38.6 Мб
```
docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
inks/ui             4.0                 6d81c7ee0a19        11 seconds ago      38.6MB
inks/ui             3.0                 9b78bf6f5ffa        About an hour ago   228MB
inks/ui             2.0                 cbd3055df020        About an hour ago   447MB
inks/ui             1.0                 4e934e3b4354        6 hours ago         958MB
alpine              latest              cdf98d1859c1        13 hours ago        5.53MB
inks/comment        1.0                 64fd9ba575f1        15 hours ago        956MB
inks/post           1.0                 aed6599b931b        16 hours ago        206MB

```
- Аналогично применяем для создания образов post-py и comment. Образы удалось сжать до 107 и 35.7 Мб соответственно
```
docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
inks/comment        2.0                 c633c5a7cded        6 seconds ago       35.7MB
inks/post           2.0                 f2a9fce39e3b        14 minutes ago      107MB
inks/ui             4.0                 6d81c7ee0a19        32 minutes ago      38.6MB
inks/ui             3.0                 9b78bf6f5ffa        2 hours ago         228MB
inks/ui             2.0                 cbd3055df020        2 hours ago         447MB
inks/ui             1.0                 4e934e3b4354        6 hours ago         958MB
alpine              latest              cdf98d1859c1        14 hours ago        5.53MB
inks/comment        1.0                 64fd9ba575f1        16 hours ago        956MB
inks/post           1.0                 aed6599b931b        17 hours ago        206MB
```

- Останаваливаем контейнеры, поднимаем новые из свежих образов
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest \
&& docker run -d --network=reddit --network-alias=post inks/post:2.0 \
&& docker run -d --network=reddit --network-alias=comment inks/comment:2.0 \
&& docker run -d --network=reddit -p 9292:9292 inks/ui:4.0
```
- Создадим Docker volume для исключения удаления данных в случае остановки контейнера
```
docker volume create reddit_db
```
- Отключаем старые копии контейнеров и пересоздаем с подключеннным хранилищем
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest \
&& docker run -d --network=reddit --network-alias=post inks/post:2.0 \
&& docker run -d --network=reddit --network-alias=comment inks/comment:2.0 \
&& docker run -d --network=reddit -p 9292:9292 inks/ui:4.0
```
- Создаем новый пост, пересоздаем контейнеры и убеждаемся, что пост остался на месте
