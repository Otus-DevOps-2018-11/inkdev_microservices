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


# Домашнее задание №17(docker-4)
Полезные команды
```
eval $(docker-machine env docker-host)
docker kill $(docker ps -q)
export USERNAME=inks
docker-compose up -d
docker-compose ps
docker-compose down 
```
- Проверяем режим работы сети none
```
 docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig
```
Убеждаемся, что из интерфейсов на борту есть только loopback
```
lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

```
- Проверяем режим работы сети host c host network driver
```
docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig
```

В выводе указаны хостовые и виртуальные интерфейсы контейнеров
```
docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig
br-f4b77fa58ff9 Link encap:Ethernet  HWaddr 02:42:E0:F8:C1:C9
          inet addr:172.18.0.1  Bcast:172.18.255.255  Mask:255.255.0.0
          inet6 addr: fe80::42:e0ff:fef8:c1c9%32521/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1814 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1866 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:124578 (121.6 KiB)  TX bytes:251997 (246.0 KiB)

docker0   Link encap:Ethernet  HWaddr 02:42:D7:EB:36:02
          inet addr:172.17.0.1  Bcast:172.17.255.255  Mask:255.255.0.0
          inet6 addr: fe80::42:d7ff:feeb:3602%32521/64 Scope:Link
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:24360 errors:0 dropped:0 overruns:0 frame:0
          TX packets:29829 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:2143059 (2.0 MiB)  TX bytes:649063556 (618.9 MiB)

ens4      Link encap:Ethernet  HWaddr 42:01:0A:84:00:07
          inet addr:10.132.0.7  Bcast:10.132.0.7  Mask:255.255.255.255
          inet6 addr: fe80::4001:aff:fe84:7%32521/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1460  Metric:1
          RX packets:108627 errors:0 dropped:0 overruns:0 frame:0
          TX packets:89453 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1246663539 (1.1 GiB)  TX bytes:9746866 (9.2 MiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1%32521/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

veth16e2ec7 Link encap:Ethernet  HWaddr 6E:6D:89:92:01:26
          inet6 addr: fe80::6c6d:89ff:fe92:126%32521/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:639568 errors:0 dropped:0 overruns:0 frame:0
          TX packets:465058 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:70757477 (67.4 MiB)  TX bytes:69569031 (66.3 MiB)

veth9fe1eba Link encap:Ethernet  HWaddr 9A:DC:10:87:97:40
          inet6 addr: fe80::98dc:10ff:fe87:9740%32521/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:522250 errors:0 dropped:0 overruns:0 frame:0
          TX packets:796277 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:82230092 (78.4 MiB)  TX bytes:86340741 (82.3 MiB)

vethd4e4640 Link encap:Ethernet  HWaddr 1A:3A:AB:03:BC:02
          inet6 addr: fe80::183a:abff:fe03:bc02%32521/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:298713 errors:0 dropped:0 overruns:0 frame:0
          TX packets:256133 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:32042795 (30.5 MiB)  TX bytes:35577615 (33.9 MiB)

vethfa0e33b Link encap:Ethernet  HWaddr 62:35:5E:5B:70:9C
          inet6 addr: fe80::6035:5eff:fe5b:709c%32521/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:198841 errors:0 dropped:0 overruns:0 frame:0
          TX packets:142132 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:22912711 (21.8 MiB)  TX bytes:16470505 (15.7 MiB)

```
Соответствует выводу команды
```
docker-machine ssh docker-host ifconfig
```

- Запускаем 4 раза команду
```
docker run --network host -d nginx
```
Вывод docker ps при этом
```
9db9f63f09ac        nginx               "nginx -g 'daemon of…"   About a minute ago   Exited (1) About a minute ago                            upbeat_jepsen
b606bcaa642d        nginx               "nginx -g 'daemon of…"   About a minute ago   Exited (1) About a minute ago                            lucid_shannon
45f3a1e4dde5        nginx               "nginx -g 'daemon of…"   About a minute ago   Exited (1) About a minute ago                            determined_mcclintock
fd2610a78bfe        nginx               "nginx -g 'daemon of…"   About a minute ago   Up About a minute                                        romantic_sinoussi

```
Статуc "Exited" говорит о том, что контейнер не запущен, потому что nginx первого контейнера занял 80 порт, остальные не могут его задествовать

- Останавливаем контейнеры 
```
 docker kill $(docker ps -q)

```
- Docker networks.
На docker-host выполняем команду
```
docker-machine ssh docker-host
sudo ln -s /var/run/docker/netns /var/run/netns
$ sudo ip netns
default
```
- Изменение списка namespace в зависимости от выбранного драйвера none или host
 - none
   ```
   docker run -d --network none joffotron/docker-net-tools
   $docker-machine ssh docker-host 'sudo ip netns'
   6de67dcdbe1c
   default
   RTNETLINK answers: Invalid argument
   RTNETLINK answers: Invalid argument

   ```
 - host
   ```
   docker run -d --network host joffotron/docker-net-tools
   $ docker-machine ssh docker-host 'sudo ip netns'
   default
   ```
- Bridge network driver

```
docker run -d --network=reddit mongo:latest \
&& docker run -d --network=reddit inks/post:1.0 \
&& docker run -d --network=reddit inks/comment:1.0 \
&& docker run -d --network=reddit -p 9292:9292 inks/ui:1.0
```
У контейнеров не выполняется сетевое взаимодействие, так как они ссылаются друг на друга в ENV переменных
Исправим с помощью алиасов
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post inks/post:1.0
docker run -d --network=reddit --network-alias=comment inks/comment:1.0
docker run -d --network=reddit -p 9292:9292 inks/ui:1.0
```
- Разносим проект по двум bridge-сетям, чтобы ui не имел доступа к БД
создаем две docker-сети 
```
> docker network create back_net --subnet=10.0.2.0/24
> docker network create front_net --subnet=10.0.1.0/24
```
Поднимаем Ui в сети front_net
```
docker run -d --network=front_net -p 9292:9292 --name ui inks/ui:1.0 \
&& docker run -d --network=back_net --name comment inks/comment:1.0 \
&& docker run -d --network=back_net --name post inks/post:1.0 \
&& docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest
```
Для успешного результата подключаем контейнеры ко второй сети
```
docker network connect front_net post
docker network connect front_net comment 
```
- Вывод сетевого стека на Linux
```
sudo docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
1af0dc47e1eb        back_net            bridge              local
c9b65fe3a70b        bridge              bridge              local
a8f44c0cd95a        front_net           bridge              local
872151e2863b        host                host                local
0ed4f163576f        none                null                local
f4b77fa58ff9        reddit              bridge              local
```
- Сделаем выборку по bridge-интерфейсам
```
$ ifconfig | grep br
br-1af0dc47e1eb Link encap:Ethernet  HWaddr 02:42:7f:0a:b0:0e
br-a8f44c0cd95a Link encap:Ethernet  HWaddr 02:42:80:04:47:8b
br-f4b77fa58ff9 Link encap:Ethernet  HWaddr 02:42:e0:f8:c1:c9
```
- Рассмотрим один из них более подробно
```
$ brctl show br-1af0dc47e1eb
bridge name     bridge id               STP enabled     interfaces
br-1af0dc47e1eb         8000.02427f0ab00e       no              veth3d520db
                                                        veth7477b93
                                                        vethb8598e8

```
- Вывод iptables
```
sudo iptables -nL -t nat
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination
DOCKER     all  --  0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL

Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
DOCKER     all  --  0.0.0.0/0           !127.0.0.0/8          ADDRTYPE match dst-type LOCAL

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  10.0.1.0/24          0.0.0.0/0
MASQUERADE  all  --  10.0.2.0/24          0.0.0.0/0
MASQUERADE  all  --  172.18.0.0/16        0.0.0.0/0
MASQUERADE  all  --  172.17.0.0/16        0.0.0.0/0
MASQUERADE  tcp  --  10.0.1.2             10.0.1.2             tcp dpt:9292

Chain DOCKER (2 references)
target     prot opt source               destination
RETURN     all  --  0.0.0.0/0            0.0.0.0/0
RETURN     all  --  0.0.0.0/0            0.0.0.0/0
RETURN     all  --  0.0.0.0/0            0.0.0.0/0
RETURN     all  --  0.0.0.0/0            0.0.0.0/0
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:9292 to:10.0.1.2:9292 #Перенаправлние трафика
```

- Проверяем работу docker-proxy
```
ps ax | grep docker-proxy
29655 ?        Sl     0:00 /usr/bin/docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 9292 -container-ip 10.0.1.2 -container-port 9292

```

### Работа c Docker-compose
- Описываем поднятие инфраструктуры в файле docker-compose.yml
- Останавливаем контейнеры и задаем переменную окружения 
```
export USERNAME=inks
```
- Применяем и проверяем запущенную инфраструктуру
```
docker-compose up -d
$ docker-compose ps
    Name                  Command             State           Ports
----------------------------------------------------------------------------
src_comment_1   puma                          Up
src_post_1      python3 post_app.py           Up
src_post_db_1   docker-entrypoint.sh mongod   Up      27017/tcp
src_ui_1        puma                          Up      0.0.0.0:9292->9292/tcp
```

- Описываем в файле docker-compose поднятие контейнеров с сетями front_net, back_net и сетевыми алиасами
Проверяем
```
$ docker-compose ps
    Name                  Command             State           Ports
----------------------------------------------------------------------------
src_comment_1   puma                          Up
src_post_1      python3 post_app.py           Up
src_post_db_1   docker-entrypoint.sh mongod   Up      27017/tcp
src_ui_1        puma                          Up      0.0.0.0:9292->9292/tcp
```
- Параметризуем с помощью переменных окружений публикуемый наружу порт ui, верcии сервисов ui, post, comment и версию mongodb. Параметры внесем в файл .env, который docker-compose подхватит при развертывании. Файл .env внесли в .gitignore. Проверим доступность приложения
- Базовое имя текущего проекта src
```
Creating network "src_back_net" with the default driver
Creating network "src_front_net" with the default driver
Creating src_ui_1      ... done
Creating src_comment_1 ... done
Creating src_post_1    ... done
Creating src_post_db_1 ... done
```
Название берется из текущей папки src, где находится файл docker-compose
Изменить можно с помощью переменной окружения
```
COMPOSE_PROJECT_NAME=dockermicroservices 
```
Проверяем
```
docker-compose up -d
Creating network "dockermicroservices_back_net" with the default driver
Creating network "dockermicroservices_front_net" with the default driver
Creating volume "dockermicroservices_post_db" with default driver
Creating dockermicroservices_comment_1 ... done
Creating dockermicroservices_post_db_1 ... done
Creating dockermicroservices_post_1    ... done
Creating dockermicroservices_ui_1      ... done

```
 
### Задание со *

Для того, чтобы реализовать изменение кода без сборки образа , подключим необходимые файлs в качестве volume'ов

```
docker-machine scp -r ./src docker-host:/home/docker-user/
```
Подключаемся, проверяем доступность папки src
```
docker-machine ssh docker-host
ls -al /src
```
 - Добавляем в запуск пумы и руби два воркера(флаги --debug и -w 2) с помощью конструкции entrypoint

```
 entrypoint:
    - puma
    - --debug
    - -w 2
```
- Сводим в итоговый файл сценария docker-compose.override.yml
- Поднимаем инфраструктуру
```
 docker-compose up -d
Creating network "src_front_net" with the default driver
Creating network "src_back_net" with the default driver
Creating src_comment_1 ... done
Creating src_post_db_1 ... done
Creating src_post_1    ... done
Creating src_ui_1      ... done
```
- Создаем пост со ссылкой, перезапускаем контейнеры, убеждаемся, что благодарая volume пост остался на месте. Проверяем наличие воркеров
```
$ docker-compose ps
    Name                  Command             State           Ports
----------------------------------------------------------------------------
src_comment_1   puma --debug -w 2             Up
src_post_1      python3 post_app.py           Up
src_post_db_1   docker-entrypoint.sh mongod   Up      27017/tcp
src_ui_1        puma --debug -w 2             Up      0.0.0.0:9292->9292/tcp
```

### Домашнее задание №19(gitlab-ci)
- Поднимаем инстанс в GCP
- Устанавливаем Docker
- Подготавливаем окружение для gitlab и omnibus установки
```
# mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs
# cd /srv/gitlab/
# touch docker-compose.yml

web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab.example.com'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'http://<YOUR-VM-IP>'
  ports:
    - '80:80'
    - '443:443'
    - '2222:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'

```
- Запускаем gitlab
```
docker-compose up -d
```
- Заходим, создаем группу homework
- Создаем проект example
- Добавляем remote в свой репозиторий
```
> git checkout -b gitlab-ci-1
> git remote add gitlab http://<your-vm-ip>/homework/example.git
> git push gitlab gitlab-ci-1
```
- Добавляем пайплайн c помощью файла gitlab-ci.yml
- Сохраняем, пушим и проверяем, что пайплайн готов к старту
```
> git add .gitlab-ci.yml
> git commit -m 'add pipeline definition'
> git push gitlab gitlab-ci-1
```
- Создаем раннер на сервере Gitlab
```
sudo docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest 

```
- Регистрируем раннер
```
sudo docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false
```
- Заполняем интерактивный опрос и получаем работающий раннер
```
Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
http://<YOUR-VM-IP>/
Please enter the gitlab-ci token for this runner:
<TOKEN>
Please enter the gitlab-ci description for this runner:
[38689f5588fe]: my-runner
Please enter the gitlab-ci tags for this runner (comma separated):
linux,xenial,ubuntu,docker
Please enter the executor:
docker
Please enter the default Docker image (e.g. ruby:2.1):
alpine:latest
Runner registered successfully.

```

- Провреряем статус через CI/CD pipeline
- Добавляем приложение Reddit в наш репозиторий
- Изменяем пайплайн для запуска теста
```
image: ruby:2.4.2
stages:
...
variables:
 DATABASE_URL: 'mongodb://mongo/user_posts'
before_script:
 - cd reddit
 - bundle install
...
test_unit_job:
 stage: test
 services:
 - mongo:latest
 script:
 - ruby simpletest.rb 
```
- Пишем сам тест simpletest.rb
```
require_relative './app'
require 'test/unit'
require 'rack/test'
set :environment, :test
class MyAppTest < Test::Unit::TestCase
 include Rack::Test::Methods
 def app
 Sinatra::Application
 end
 def test_get_request
 get '/'
 assert last_response.ok?
 end
end
```
- Добавляем бибилиотеку тестирования в Gemfile
```
gem 'rack-test'
```
- Изменяем пайплайн, чтобы при job deploy код выкатывался на окружение dev
```
stages:
 - build
 - test
 - review
...
build_job:
...
test_unit_job:
...
test_integration_job:
...
deploy_dev_job:
 stage: review
 script:
 - echo 'Deploy'
 environment:
 name: dev
 url: http://dev.example.com
```
- Проверяем окружение в Operations-Environments
- Определяем еще два окружения Staging И Production. Добавляем запуск с кнопки
```
stages:
 - build
 - test
 - review
 - stage
 - production

staging:
 stage: stage
 when: manual
 script:
   - echo 'Deploy'
 environment:
   name: stage
   url: https://beta.example.com

production:
 stage: production
 when: manual
 script:
   - echo 'Deploy'
 environment:
   name: production
   url: https://example.com
```
- Добавляем в пайплайн директиву, не позволяющую деплоить в окружения stage и prod без тега git
```
only:
   - /^\d+\.\d+\.\d+/
```
- Проверяем с тегом
```
git commit -a -m ‘#4 add logout button to profile page’
git tag 2.4.10
git push gitlab gitlab-ci-1 --tags
```

- Динамические окружения
Добавляем job, который определяет динамическое окружение для всех веток в репозитории, кроме ветки master
```
branch review:
 stage: review
 script: echo "Deploy to $CI_ENVIRONMENT_SLUG"
 environment:
 name: branch/$CI_COMMIT_REF_NAME
 url: http://$CI_ENVIRONMENT_SLUG.example.com
 only:
 - branches
 except:
 - master
```

### Домашнее задание №20(monitoring-1)
- Создаем инстанс в GCP, создаем правила, подключаем к docker-machine, скачиваем базовый образ prometheus, разворачиваем, изучаем интерфейс, останавливаем контейнер
```
$ gcloud compute firewall-rules create prometheus-default --allow tcp:9090 --project=docker-....

$ gcloud compute firewall-rules create puma-default --allow tcp:9292

$ export GOOGLE_PROJECT=_ваш-проект_

# create docker host
docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-zone europe-west1-b \
    docker-host

# configure local env
eval $(docker-machine env docker-host)

$ docker run --rm -p 9090:9090 -d --name prometheus  prom/prometheus

$ docker-machine ip docker-host

$ docker stop prometheus
```
Metrics
Targets-системы или процессы, за которыми следит prometheus
- Создаем Dockerfile
```
FROM prom/prometheus:v2.1.0
ADD prometheus.yml /etc/prometheus/
```
- Конфигурируем
```
---
global:
  scrape_interval: '5s' #частота сборки

scrape_configs:
  - job_name: 'prometheus' #Джобы объединяют в группы endpoint-ы,выполняющиеодинаковую функцию
    static_configs:
      - targets:
        - 'localhost:9090' #Адреса для сбора метрик

  - job_name: 'ui'
    static_configs:
      - targets:
        - 'ui:9292'

  - job_name: 'comment'
    static_configs:
      - targets:
        - 'comment:9292'
```
- Собираем образ
```
$ export USER_NAME=username
$ docker build -t $USER_NAME/prometheus .
```
- Собираем три контейнера с healthcheck со скриптами
```
for i in ui post-py comment; do cd src/$i; bash
docker_build.sh; cd -; done
```
- Правим docker-compose.yml и .env файлы для билда посредством директивы image
- Проверяем работоспособность reddit и prometheus
- Проверяем healthcheck сервиса ui
- Останавливаем сервис Post
- Проверяем по Graph, что сервис ui деградировал, как и сервис ui_health_post_availability
- Поднимаем, убеждаемся, что все сервисы работают корректно

- Установка node_exporter. Добавляем в docker-compose файл
```
...
services:

  node-exporter:
    image: prom/node-exporter:v0.15.2
    user: root
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points="^/(sys|proc|dev|host|etc)($$|/)"'
```
- Добавляем job в конфиг prometheus
```
- job_name: 'node'
 static_configs:
 - targets:
 - 'node-exporter:9100'
 ```
 - Собираем новый docker-image
 ```
 monitoring/prometheus $ docker build -t $USER_NAME/prometheus .
 ```

 ### Задание со * №1
 - Добавить в Prometheus мониторинг MongoDB
 - Используем percona exporter, используем последнюю актуальную версию 0.7.0
 ```
 https://github.com/percona/mongodb_exporter
 ```
 - Копируем Dockerfile из репозитория, создаем на его основе свой
 - Делаем билд и пушим на docker-hub 
 ```
 cd monitoring/mongodb-exporter/
 export USER_NAME=inks
 docker build -t $USER_NAME/mongodb-exporter .
 docker push $USER_NAME/mongodb-exporter
 ```
 - Добавляем запуск exporter в файл docker/docker-compose.yml
 ```
 mongodb-exporter:
    image: ${USERNAME}/mongodb-exporter:latest
    ports:
      - '9216:9216'
    command:
      - '--collect.database'
      - '--collect.collection'
      - '--collect.indexusage'
      - '--collect.topmetrics'
      - '--mongodb.uri=mongodb://post_db:27017'
    networks:
      back_net:
        aliases:
          - mongodb-exporter
 ```
 - Добавляем job mongodb в файл prometheus.yml
 ```
 - job_name: 'mongodb'
    static_configs:
      - targets:
        - 'mongodb-exporter:9216'
 ```

 - Пересобираем prometheus и пушим в репозиторий

 ```
 docker build -t $USER_NAME/prometheus .
 docker push $USER_NAME/prometheus
 ```

 - Выключаем старое окружение, поднимаем новое
 ```
 docker-compose down
 docker-compose up -d
 ```
 - Проверяем работоспособность

### Задание со * №2 
Добавить в проект мониторинг сервисов comment post ui с помощью blackbox или cloudprober экспортера
Используем cloudprober https://github.com/google/cloudprober
- Собираем контейнер через Dockerfile, настраиваем probe в cloudprober.cfg
```
docker-build -t $USER_NAME/cloudprober
docker push $USER_NAME/cloudprober
```
- Добавляем job в prometheus.yml
```
- job_name: 'cloudprober'
    static_configs:
      - targets:
        - 'cloudprober:9313'
```
- Добавляем описание контейнера в docker-compose, переподнимаем
- Проверяем , открыв предварительно порт cloudprober 9313
```
http://ext_ip:9313/metrics
```

### Задание со * №3
- Создаем Makefile, в котором описываем последовательность действий по созданию контейнеров и пушу в docker-hub


### Домашнее задание №21(monitoring-2)
Полезные команды
```
eval $(docker-machine env docker-host)
docker-machine ip docker-host
docker build -t $USER_NAME/prometheus .
docker push $USER_NAME/prometheus
```
- Рефакторим код docker-compose.yml: мониторинг выносим в отдельный файл docker-compose-monitoring.yml
Поднимать будем командами
```
docker-compose up -d
docker-compose -f docker-compose-monitoring.yml up -d
```
- Добавляем cAdvisor в docker-compose-monitoring.yml
- Добавляем Job в prometheus
```
 - job_name: 'cadvisor'
    static_configs:
      - targets:
      - 'cadvisor:8080' 
```
- Пересобираем Prometheus, запускаем docker-compose
```
$ docker-compose up -d
$ docker-compose -f docker-compose-monitoring.yml up -d 
```
- Поднимаем, убеждаемся в работе cadvisor, проверяем что метрики 'container' доступны

Grafana
- Добавляем новый сервис
- Запускаем новый сервис
```
docker-compose -f docker-compose-monitoring.yml up -d grafana
```
- Заходим по внешнему адресу порт 3000, проверяем доступность, добавляем новый ресурс prometheus
- Качаем с сайта Grafana json дашбоарда для мониторинга Docker, импортируем его в Grafana
- Проверяем работу dashboard'а

Сбор метрик приложения
- Добавляем job для сбора информации о post сервисе
- Пересобираем prometheus, переподнимаем окружение с мониторингом
- Делаем несколько постов в приложении
- В Grafana создаем dashboard с графиком ui_request_count. Сохраняем dashboard
- Создаем второй график, показывающий количество неудачных http запросов с кодом ошибки 4xx и 5xx.  
```
Будем использовать
функцию rate(), чтобы посмотреть не просто значение счетчика за
весь период наблюдения, но и скорость увеличения данной
величины за промежуток времени (возьмем, к примеру 1-минутный
интервал, чтобы график был хорошо видим)
rate(ui_request_count{http_status=~"^[45].*"}[1m])
```
- Делаем несколько запросов по адресу http://ext_ip:9292/nonexistent, проверяем, что график изменился
- На первом графике делаем аналогичный rate 
```
rate(ui_request_count[1m])
```
- Использование гистограммы. Построили гистограмму с использованием 95 процентиля для метрики ui_request_response_time_bucket
```
histogram_quantile(0.95, sum(rate(ui_request_response_time_bucket[5m])) by (le))
```
- Сохранили и выгрузили дашбоард в файл UI_Service_Monitoring.json
- Реализовали мониторинг бизнес-логики (счетчики количества постов и комментариев). Вынесли в отдельный dashboard и экспортировали в файл Business_Logic_Monitoring.json

Алертинг
- Используем alertmanager от prometheus
- Создаем контейнер с включенной интеграцией со слак-каналом
- Останавливаем сервис post, проверяем наличие сообщения

- Пушим наши образы на dockerhub
```
$ docker login
Login Succeeded
$ docker push $USER_NAME/ui
$ docker push $USER_NAME/comment
$ docker push $USER_NAME/post
$ docker push $USER_NAME/prometheus
$ docker push $USER_NAME/alertmanager 
```
- Необходимые образы находятся по адресу https://hub.docker.com/u/inks/

### Задание со *
1. Изменение Makefile
- Добавляем образы alertmanager в Makefile
2. Выдача метрик в Prometheus средствами Docker
- Добавляем сбор метрик Docker в Prometheus https://docs.docker.com/config/thirdparty/prometheus/
 - На Dockerhost создаем файл в соответствии с документацией /etc/docker/daemon.json
 ```
 {
  "metrics-addr" : "0.0.0.0:9323",
  "experimental" : true
 }
 ```
 - В prometheus добавляем job docker
 ```
 - job_name: 'docker'
    static_configs:
      - targets: 
        - 'internal_docker_host_ip:9323'
 ```
 - Набор метрик стандартный, ориентирован на мониторинг сервиса docker и заметно скуднее, чем в cAdvisor, где помимо cpu, RAM есть подробные метрики мониторинга файловой системы, кол-ва полученных пакетов итд
 - Для визуализации используем готовый дашбоард Docker Engine Metrics https://grafana.com/dashboards/1229

3. Сбор метрик с помощью Telegraf от influxDB
  - Конфигурируем telegraf с помощью файла https://github.com/influxdata/telegraf/blob/master/etc/telegraf.conf
  - Заполняем секцию [[inputs.docker]]
  - Собираем контейнер с telegraf
  - Собираем дашбоард, выгружаем

4. Создали алерт HTTPHighTimeResponse на 95 процентиль времени ответа HTTP, проверили отправку алерта с заниженным порогом срабатывания
5. Настроили оповещение на электронную почту, для этого поменяли конфиг в alertmanager. Проверили приходящие алерты


### Домашнее задание №23(logging-1)
- Создаем хост logging
- Пересобираем образы в каталоге src
- Поднимаем окружение
- Собираем контейнер для fluentd
```
Из директории logging/fluentd
docker build -t $USER_NAME/fluentd .
```

Структурированные логи
- Подключаем драйвер для отправки логов во fluentd. Используем docker-драйвер
- Создаем несколько постов
- Переходим в интерфейс kibana

```
docker-machine ssh logging
sudo sysctl -w vm.max_map_count=262144
```

Неструктурированные логи
- Для парсинга неструктурированных логов сервиса ui будем использовать регулярные выражения
```
<filter service.ui>
  @type parser
  format /\[(?<time>[^\]]*)\]  (?<level>\S+) (?<user>\S+)[\W]*service=(?<service>\S+)[\W]*event=(?<event>\S+)[\W]*(?:path=(?<path>\S+)[\W]*)?request_id=(?<request_id>\S+)[\W]*(?:remote_addr=(?<remote_addr>\S+)[\W]*)?(?:method= (?<method>\S+)[\W]*)?(?:response_status=(?<response_status>\S+)[\W]*)?(?:message='(?<message>[^\']*)[\W]*)?/
  key_name log
</filter>
```
- Проверяем работу парсера
- Используем grok-шаблон

### Задание со *
- Создадим фильтр для парсинга логов ui таким образом, чтобы разбирались два формата представления. Конфигурацию разделим с помощью тегов <grok></grok>
```
<grok>
    pattern service=%{WORD:service} \| event=%{WORD:event} \| request_id=%{GREEDYDATA:request_id} \| message='%{GREEDYDATA:message}'
  </grok>
  <grok>
    pattern service=%{WORD:service} \| event=%{WORD:event} \| path=%{PATH:path} \| request_id=%{GREEDYDATA:request_id} \| remote_addr=%{IP:remote_addr} \| method= %{WORD:method} \| response_status=%{NUMBER:response_status}
  </grok>
```

### Задание с ***
Используем систему распределенного трейсинга Zipkin
- Собираем проблемное приложение, убеждаемся, что ответ при нажатии довольно медленный.
- По трейсингу Zipkin видим, что запрос post.get занимает 3.019 сек. 

### Домашнее задание №25(kubernetes-1)

The Hard way
Полезные команды
```
#Tmux
tmux-зайти в режим
ctrl b c создать окно
ctrl b x удалить окно/pane
ctrl b " горизонтальный pane
ctrl b % вертикальный pane
ctrl b shift : режим ввода команд
ctrl b shift : set syncronize-panes on включить синхронизацию между panes
ctrl b shift : set syncronize-panes off выключить синхронизацию между panes
ctrl b arrow up, arrow down перемещение между горизонтальными окнами
exit
```
1. Prerequisites
Проверяем дефолт регион и зону, выставляем Европу
```
gcloud config set compute/region europe-west1
Updated property [compute/region]
gcloud config set compute/zone europe-west1-b
Updated property [compute/zone]
```
2. Installing the Client Tools
Инсталлируем cfssl и cfssljson, проверяем
```
cfssl version
Version: 1.2.0
Revision: dev
Runtime: go1.6
```
Инсталлируем kubectl
```
kubectl version --client
Client Version: version.Info{Major:"1", Minor:"12", GitVersion:"v1.12.0", GitCommit:"0ed33881dc4355495f623c6f22e7dd0b7632b7c0", GitTreeState:"clean", BuildDate:"2018-09-27T17:05:32Z", GoVersion:"go1.10.4", Compiler:"gc", Platform:"linux/amd64"}
```

3. Provisioning Compute Resources
Создаем подсети, назначаем адресацию
```
gcloud compute networks create kubernetes-the-hard-way --subnet-mode custom

NAME                     SUBNET_MODE  BGP_ROUTING_MODE  IPV4_RANGE  GATEWAY_IPV4
kubernetes-the-hard-way  CUSTOM       REGIONAL

Instances on this network will not be reachable until firewall rules
are created. As an example, you can allow all internal traffic between
instances as well as SSH, RDP, and ICMP by running:

$ gcloud compute firewall-rules create <FIREWALL_NAME> --network kubernetes-the-hard-way --allow tcp,udp,icmp --source-ranges <IP_RANGE>
$ gcloud compute firewall-rules create <FIREWALL_NAME> --network kubernetes-the-hard-way --allow tcp:22,tcp:3389,icmp

alexis@inkdev:~/kubectl$ gcloud compute networks subnets create kubernetes \
>   --network kubernetes-the-hard-way \
>   --range 10.240.0.0/24

NAME        REGION        NETWORK                  RANGE
kubernetes  europe-west1  kubernetes-the-hard-way  10.240.0.0/24
```
Создаем основные правила фаерволла для доступа изнутри
```
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-internal \
  --allow tcp,udp,icmp \
  --network kubernetes-the-hard-way \
  --source-ranges 10.240.0.0/24,10.200.0.0/16
```
Открываем доступ по ssh, icmp, https снаружи
```
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-external \
  --allow tcp:22,tcp:6443,icmp \
  --network kubernetes-the-hard-way \
  --source-ranges 0.0.0.0/0
```
Проверяем
```
gcloud compute firewall-rules list --filter="network:kubernetes-the-hard-way"
NAME                                    NETWORK                  DIRECTION  PRIORITY  ALLOW                 DENY  DISABLED
kubernetes-the-hard-way-allow-external  kubernetes-the-hard-way  INGRESS    1000      tcp:22,tcp:6443,icmp        False
kubernetes-the-hard-way-allow-internal  kubernetes-the-hard-way  INGRESS    1000      tcp,udp,icmp                False
```
Назначаем внешний Ip-адрес, проверяем
```
gcloud compute addresses list --filter="name=('kubernetes-the-hard-way')"
```
Контроллеры
Создаем три инстанса, которые держат на себе control-plane
Создаем три инстанса с воркерами
Проверяем
```
gcloud compute instances list
NAME          ZONE            MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP     STATUS
controller-0  europe-west1-b  n1-standard-1               10.240.0.10                 RUNNING
controller-1  europe-west1-b  n1-standard-1               10.240.0.11                 RUNNING
controller-2  europe-west1-b  n1-standard-1               10.240.0.12                 RUNNING
worker-0      europe-west1-b  n1-standard-1               10.240.0.20                 RUNNING
worker-1      europe-west1-b  n1-standard-1               10.240.0.21                 RUNNING
worker-2      europe-west1-b  n1-standard-1               10.240.0.22                 RUNNING
```
Проверяем доступ по ssh
```
gcloud compute ssh controller-0
alexis@controller-0:~$
```

4. Provisioning a CA and Generating TLS Certificates
Генерируем configuration file, certificate, и private key:
```
ls
ca-config.json  ca.csr  ca-csr.json  ca-key.pem  ca.pem
```
Генерируем сертификат администратора
```
ls
admin.csr  admin-csr.json  admin-key.pem  admin.pem 
```
Генерируем клиентские сертификаты kubelet
```
ls -al
 worker-0.csr
 worker-0-csr.json
 worker-0-key.pem
 worker-0.pem
 worker-1.csr
 worker-1-csr.json
 worker-1-key.pem
 worker-1.pem
 worker-2.csr
 worker-2-csr.json
 worker-2-key.pem
 worker-2.pem
```
Генерируем сертификаты kube-controller-manager
```
kube-controller-manager.csr
kube-controller-manager-csr.json
kube-controller-manager-key.pem
kube-controller-manager.pem
```
Генерируем сертификаты kube-proxy
```
 ls -al | grep kube-proxy
kube-proxy.csr
kube-proxy-csr.json
kube-proxy-key.pem
kube-proxy.pem
```
Генерируем сертификаты kube-scheduler
```
kube-scheduler.csr
kube-scheduler-csr.json
kube-scheduler-key.pem
kube-scheduler.pem
```
Генерируем kubernetes API certificate
```
ls -al | grep kubernetes
kubernetes.csr
kubernetes-csr.json
kubernetes-key.pem
kubernetes.pem
```
Генерируем service-accout cert
```
ls -l | grep service-account
service-account.csr
service-account-csr.json
service-account-key.pem
service-account.pem
```
Распростроняем сертификаты на соответсвующие инстансы и воркеры

5. Generating Kubernetes Configuration Files for Authentication
Генерируем kubelet conf file
```
Cluster "kubernetes-the-hard-way" set.
User "system:node:worker-0" set.
Context "default" created.
Switched to context "default".
Cluster "kubernetes-the-hard-way" set.
User "system:node:worker-1" set.
Context "default" created.
Switched to context "default".
Cluster "kubernetes-the-hard-way" set.
User "system:node:worker-2" set.
Context "default" created.
Switched to context "default".

```
Генерируем kube-proxy Kubernetes Configuration File
```
Cluster "kubernetes-the-hard-way" set.
User "system:kube-proxy" set.
Context "default" created.
Switched to context "default".
```
Генерируем conroller-manager
```
Cluster "kubernetes-the-hard-way" set.
User "system:kube-controller-manager" set.
Context "default" created.
Switched to context "default".
```
Генерируем kube-scheduler
```
Cluster "kubernetes-the-hard-way" set.
User "system:kube-scheduler" set.
Context "default" created.
Switched to context "default".
```
Генерируем kubeconfig для админа
```
Cluster "kubernetes-the-hard-way" set.
User "admin" set.
Context "default" created.
Switched to context "default".

```
Распространяем kubelet и kube-proxy kubeconfig files на каждый из экземпляров воркера

6. Generating the Data Encryption Config and Key
Генерируем ключ шифрования и шифруем секреты кубера

7. Bootstrapping the etcd Cluster
Заходим с помощью tmux параллельно на три контроллера 
Устанавливаем  конфигурируем и запускаем etcd server
```
3a57933972cb5131, started, controller-2, https://10.240.0.12:2380, https://10.240.0.12:2379
f98dc20bce6225a0, started, controller-0, https://10.240.0.10:2380, https://10.240.0.10:2379
ffed16798470cab5, started, controller-1, https://10.240.0.11:2380, https://10.240.0.11:2379

```

8. Bootstrapping the Kubernetes Control Plane
```
kubectl get componentstatuses --kubeconfig admin.kubeconfig
NAME                 STATUS    MESSAGE             ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-2               Healthy   {"health":"true"}
etcd-1               Healthy   {"health":"true"}
etcd-0               Healthy   {"health":"true"}
```

Test nginx HTTP health check proxy
```
curl -H "Host: kubernetes.default.svc.cluster.local" -i http://127.0.0.1/healthz
HTTP/1.1 200 OK
Server: nginx/1.14.0 (Ubuntu)
Date: Tue, 23 Apr 2019 08:30:14 GMT
Content-Type: text/plain; charset=utf-8
Content-Length: 2
Connection: keep-alive

ok
```
Kubernetes frontend load balancer
```
{
  "major": "1",
  "minor": "12",
  "gitVersion": "v1.12.0",
  "gitCommit": "0ed33881dc4355495f623c6f22e7dd0b7632b7c0",
  "gitTreeState": "clean",
  "buildDate": "2018-09-27T16:55:41Z",
  "goVersion": "go1.10.4",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

9. Bootstrapping the Kubernetes Worker Nodes

Проверка
```
gcloud compute ssh controller-0 \
>   --command "kubectl get nodes --kubeconfig admin.kubeconfig"
NAME       STATUS   ROLES    AGE   VERSION
worker-0   Ready    <none>   86s   v1.12.0
worker-1   Ready    <none>   85s   v1.12.0
worker-2   Ready    <none>   86s   v1.12.0
```

10. Configuring kubectl for Remote Access
```
kubectl get componentstatuses
NAME                 STATUS    MESSAGE             ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-0               Healthy   {"health":"true"}
etcd-1               Healthy   {"health":"true"}
etcd-2               Healthy   {"health":"true"}

 kubectl get nodes
NAME       STATUS   ROLES    AGE    VERSION
worker-0   Ready    <none>   8m6s   v1.12.0
worker-1   Ready    <none>   8m5s   v1.12.0
worker-2   Ready    <none>   8m6s   v1.12.0

```

11. Provisioning Pod Network Routes
```
for instance in worker-0 worker-1 worker-2; do
>   gcloud compute instances describe ${instance} \
>     --format 'value[separator=" "](networkInterfaces[0].networkIP,metadata.items[0].value)'
> done
10.240.0.20 10.200.0.0/24
10.240.0.21 10.200.1.0/24
10.240.0.22 10.200.2.0/24

```

```
NAME                            NETWORK                  DEST_RANGE     NEXT_HOP                  PRIORITY
default-route-1afeb1fda6959d8f  kubernetes-the-hard-way  0.0.0.0/0      default-internet-gateway  1000
default-route-e1a84a5413e4626d  kubernetes-the-hard-way  10.240.0.0/24  kubernetes-the-hard-way   1000
kubernetes-route-10-200-0-0-24  kubernetes-the-hard-way  10.200.0.0/24  10.240.0.20               1000
kubernetes-route-10-200-1-0-24  kubernetes-the-hard-way  10.200.1.0/24  10.240.0.21               1000
kubernetes-route-10-200-2-0-24  kubernetes-the-hard-way  10.200.2.0/24  10.240.0.22               1000

```

12. Deploying the DNS Cluster Add-on
```
 kubectl get pods -l k8s-app=kube-dns -n kube-system
NAME                       READY   STATUS    RESTARTS   AGE
coredns-699f8ddd77-plwws   1/1     Running   0          39s
coredns-699f8ddd77-wc64p   1/1     Running   0          39s

kubectl get pods -l run=busybox
NAME                      READY   STATUS    RESTARTS   AGE
busybox-bd8fb7cbd-f6wnx   1/1     Running   0          28s


kubectl exec -ti $POD_NAME -- nslookup kubernetes
Server:    10.32.0.10
Address 1: 10.32.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.32.0.1 kubernetes.default.svc.cluster.local

```

13. Smoke test
Data encryption check
```
gcloud compute ssh controller-0 \
>   --command "sudo ETCDCTL_API=3 etcdctl get \
>   --endpoints=https://127.0.0.1:2379 \
>   --cacert=/etc/etcd/ca.pem \
>   --cert=/etc/etcd/kubernetes.pem \
>   --key=/etc/etcd/kubernetes-key.pem\
>   /registry/secrets/default/kubernetes-the-hard-way | hexdump -C"
00000000  2f 72 65 67 69 73 74 72  79 2f 73 65 63 72 65 74  |/registry/secret|
00000010  73 2f 64 65 66 61 75 6c  74 2f 6b 75 62 65 72 6e  |s/default/kubern|
00000020  65 74 65 73 2d 74 68 65  2d 68 61 72 64 2d 77 61  |etes-the-hard-wa|
00000030  79 0a 6b 38 73 3a 65 6e  63 3a 61 65 73 63 62 63  |y.k8s:enc:aescbc|
00000040  3a 76 31 3a 6b 65 79 31  3a 4d e3 0f 28 63 bc d6  |:v1:key1:M..(c..|
00000050  4f a5 2a 4f 0e f3 08 cd  fb 11 c9 ea 62 a4 81 2c  |O.*O........b..,|
00000060  8e 82 b4 f5 64 fc 2a 6a  87 df df 3e 9e f4 af 01  |....d.*j...>....|
00000070  59 31 9b 2a 60 c6 70 70  04 27 b7 f8 91 04 de c8  |Y1.*`.pp.'......|
00000080  14 07 20 fd af a5 20 b4  4b f5 03 f3 be ad 1b 0b  |.. ... .K.......|
00000090  20 4e c9 10 ee 72 9d 9a  6c 27 a5 dc 0d e4 3d 74  | N...r..l'....=t|
000000a0  95 3c 79 56 b9 08 91 28  2b 81 bb 26 95 d9 8d 4c  |.<yV...(+..&...L|
000000b0  d7 ee 10 03 8d 51 60 7b  24 c4 5e ec 7a cd e6 4e  |.....Q`{$.^.z..N|
000000c0  9d 67 de e4 a2 e2 0c 40  8f 65 b1 50 eb 21 e2 07  |.g.....@.e.P.!..|
000000d0  ad c3 f8 19 44 e3 ac 6f  db 09 42 48 93 b1 1e 75  |....D..o..BH...u|
000000e0  e3 be 67 06 48 8e 4b d8  fb 0a                    |..g.H.K...|
000000ea

```

Deployments check
```
kubectl get pods -l run=nginx
NAME                    READY   STATUS    RESTARTS   AGE
nginx-dbddb74b8-4pm45   1/1     Running   0          32s

```

Check port forwarding
```
curl --head http://127.0.0.1:8080
HTTP/1.1 200 OK
Server: nginx/1.15.12
Date: Tue, 23 Apr 2019 20:07:42 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 16 Apr 2019 13:08:19 GMT
Connection: keep-alive
ETag: "5cb5d3c3-264"
Accept-Ranges: bytes

```

Logs check
```
kubectl logs $POD_NAME
127.0.0.1 - - [23/Apr/2019:20:07:42 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.52.1" "-"
```

Execute command in container check
```
 kubectl exec -ti $POD_NAME -- nginx -v
nginx version: nginx/1.15.12

```
Services check
```
kubectl expose deployment nginx --port 80 --type NodePort

curl -I http://${EXTERNAL_IP}:${NODE_PORT}
HTTP/1.1 200 OK
Server: nginx/1.15.12
Date: Tue, 23 Apr 2019 20:12:30 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 16 Apr 2019 13:08:19 GMT
Connection: keep-alive
ETag: "5cb5d3c3-264"
Accept-Ranges: bytes

```

Untrusted workloads check
```
 sudo runsc --root /run/containerd/runsc/k8s.io ps ${CONTAINER_ID}
I0423 20:15:03.902068   29057 x:0] ***************************
I0423 20:15:03.902228   29057 x:0] Args: [runsc --root /run/containerd/runsc/k8s.io ps 413f15e735b8b8c11bffd421436423514dab787009fca1729acf1b33944bef54]
I0423 20:15:03.902311   29057 x:0] Git Revision: 50c283b9f56bb7200938d9e207355f05f79f0d17
I0423 20:15:03.902383   29057 x:0] PID: 29057
I0423 20:15:03.902454   29057 x:0] UID: 0, GID: 0
I0423 20:15:03.902523   29057 x:0] Configuration:
I0423 20:15:03.902580   29057 x:0]              RootDir: /run/containerd/runsc/k8s.io
I0423 20:15:03.902721   29057 x:0]              Platform: ptrace
I0423 20:15:03.902858   29057 x:0]              FileAccess: exclusive, overlay: false
I0423 20:15:03.902990   29057 x:0]              Network: sandbox, logging: false
I0423 20:15:03.903124   29057 x:0]              Strace: false, max size: 1024, syscalls: []
I0423 20:15:03.903266   29057 x:0] ***************************
UID       PID       PPID      C         STIME     TIME      CMD
0         1         0         0         20:13     10ms      app
I0423 20:15:03.904642   29057 x:0] Exiting with status: 0

```

Добавляем deployments (ui, post, mongo, comment) и проверяем запуск подов

```
kubectl apply -f ui-deployment.yml
deployment.apps/ui-deployment created
alexis@inkdev:~/inkdev_microservices/kubernetes/reddit$ kubectl apply -f post-deployment.yml
deployment.apps/post-deployment created
alexis@inkdev:~/inkdev_microservices/kubernetes/reddit$ kubectl apply -f mongo-deployment.yml
deployment.apps/mongo-deployment created
alexis@inkdev:~/inkdev_microservices/kubernetes/reddit$ kubectl apply -f comment-deployment.yml
deployment.apps/comment-deployment created
alexis@inkdev:~/inkdev_microservices/kubernetes/reddit$ kubectl get pods -o wide
NAME                                 READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE
busybox-bd8fb7cbd-f6wnx              1/1     Running   13         13h   10.200.0.2   worker-0   <none>
comment-deployment-687ddff64-2kh56   1/1     Running   0          10s   10.200.0.4   worker-0   <none>
mongo-deployment-6895dffdf4-w7znw    1/1     Running   0          39s   10.200.1.4   worker-1   <none>
nginx-dbddb74b8-4pm45                1/1     Running   0          13h   10.200.0.3   worker-0   <none>
post-deployment-84cc8f5c88-tmq95     1/1     Running   0          45s   10.200.2.4   worker-2   <none>
ui-deployment-69974fdf6-kpwg4        1/1     Running   0          66s   10.200.1.3   worker-1   <none>
untrusted                            1/1     Running   0          12h   10.200.2.3   worker-2   <none>
```
Все созданные в процессе прохождения the hard way файлы, кроме бинарных,  перенесены в папку the_hard_way

14. Удаляем ресурсы

### Задание с *

Описать установку компонентов Kubernetes из THW в виде Ansible-плейбука в папке kubernetes/ansible
- Создали несколько блоков плейбука, отвечающих за создание сети, правил внешнего и внутреннего фаерволла, убедились в корректной работе
Для работы с GCP использовали модуль ansible gce
```
ansible-playbook playbooks/compute_resources.yml


PLAY [Provision networks & firewall] *********************************************************************************************************************************

TASK [Virtual Private Cloud Network] *********************************************************************************************************************************
ok: [localhost]

TASK [Firewall external] *********************************************************************************************************************************************
ok: [localhost]

TASK [Firewall internal] *********************************************************************************************************************************************
ok: [localhost]

TASK [external_ip] ***************************************************************************************************************************************************
ok: [localhost]

PLAY RECAP ***********************************************************************************************************************************************************
localhost                  : ok=4    changed=0    unreachable=0    failed=0

```

### Домашнее задание №26(kubernetes-2)

Полезные команды
```
kubectl config current-context #Текущий контекст
minikube

kubectl config get-contexts #Список всех контекстов
CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
*         minikube   minikube   minikube
#Отладка
kubectl get pods -o wide --all-namespaces

```

- Устанавливаем VirtualBox
- Устанавливаем последнюю версию minikube. https://kubernetes.io/docs/tasks/tools/install-minikube/#cleanup-everything-to-start-fresh
```
minikube start
o   minikube v1.0.0 on linux (amd64)
$   Downloading Kubernetes v1.14.0 images in the background ...
>   Creating virtualbox VM (CPUs=2, Memory=2048MB, Disk=20000MB) ...
@   Downloading Minikube ISO ...

 142.88 MB / 142.88 MB [============================================] 100.00% 0s
-   "minikube" IP address is 192.168.99.107
-   Configuring Docker as the container runtime ...
-   Version of container runtime is 18.06.2-ce
:   Waiting for image downloads to complete ...
-   Preparing Kubernetes environment ...
@   Downloading kubelet v1.14.0
@   Downloading kubeadm v1.14.0
-   Pulling images required by Kubernetes v1.14.0 ...
-   Launching Kubernetes v1.14.0 using kubeadm ...
:   Waiting for pods: apiserver proxy etcd scheduler controller dns
-   Configuring cluster permissions ...
-   Verifying component health .....
+   kubectl is now configured to use "minikube"
=   Done! Thank you for using minikube!

``` 
- Проверяем запуск
```
kubectl get nodes
NAME       STATUS   ROLES    AGE     VERSION
minikube   Ready    master   7m50s   v1.14.0

```
- Проверяем текущий контекст 
```
 kubectl config current-context
```

- Список всех контекстов
```
 kubectl config get-contexts
CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
*         minikube   minikube   minikube
```

- Деплоим наше приложение

- Запускаем создание ui-компоненты на основе манифеста ui-deployment. Пробрасываем порты из Podа. Проверяем доступность приложения по адресу localhost:8080 
```
kubectl apply -f ui-deployment.yml
deployment.apps/ui created
kubectl get deployment
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
ui     3/3     3            3           77s
alexis@vagrant:~/kubernetes/reddit$ kubectl get pods --selector component=ui
NAME                  READY   STATUS    RESTARTS   AGE
ui-694844975f-4cgvw   1/1     Running   0          3m18s
ui-694844975f-qlsvb   1/1     Running   0          3m18s
ui-694844975f-xhx27   1/1     Running   0          3m18s
alexis@vagrant:~/kubernetes/reddit$ kubectl port-forward <pod-name> 8080:9292
-bash: pod-name: Нет такого файла или каталога
alexis@vagrant:~/kubernetes/reddit$ kubectl port-forward ui-694844975f-4cgvw 8080:9292
Forwarding from 127.0.0.1:8080 -> 9292
Forwarding from [::1]:8080 -> 9292

Handling connection for 8080
```
- Запускаем создание comment-компоненты на основе манифеста comment-deployment. Пробрасываем порты из Podа. Проверяем доступность приложения по адресу localhost:8080/healthcheck
```
kubectl apply -f comment-deployment.yml
deployment.apps/comment created
a
alexis@vagrant:~/kubernetes/reddit$ kubectl get pods --selector component=comment
NAME                       READY   STATUS    RESTARTS   AGE
comment-6f9644bc85-q26w2   1/1     Running   0          41s
comment-6f9644bc85-q4cws   1/1     Running   0          41s
comment-6f9644bc85-t6twq   1/1     Running   0          41s
alexis@vagrant:~/kubernetes/reddit$ kubectl port-forward comment-6f9644bc85-q26w2 8080:9292
Forwarding from 127.0.0.1:8080 -> 9292
Forwarding from [::1]:8080 -> 9292
Handling connection for 8080
Handling connection for 8080
Handling connection for 8080

```
- Поднимаем mongo
- Для взаимодействия ui с comment поднимаем comment-service и post-service.yml
```
kubectl describe service comment | grep Endpoints
Endpoints:         172.17.0.11:9292,172.17.0.4:9292,172.17.0.6:9292

kubectl exec -ti ui-694844975f-8gcsd nslookup comment
nslookup: can't resolve '(null)': Name does not resolve

Name:      comment
Address 1: 10.110.40.234 comment.default.svc.cluster.local

```
- Поднимаем сервис для Mongo mongodb-service.yml
- Создаем сервисы для взаимодействия компонентов приложения:
 - comment-mongodb-service.yml и post-mongodb-service.yml
 - mongo-deployment.yml
 - Добавляем env в comment-deployment.yml и post-deployment.yml
 - обеспечиваем доступ к приложению снаружи ui-service.yml, пробрасываем на порт 32092
 NodePort - для доступа снаружи кластера
 port - для доступа к сервису изнутри кластера
Minikube может выдавать web-странцы с сервисами которые были помечены типом NodePort
```
minikube service ui #перебросит на страницу в браузере
minikube service list 
```
Просмотр расширений
```
minikube addons list
minikube addons enable dashboard
-   dashboard was successfully enabled

```

## Работа с namespaces
- Создаем namespace dev
```
kubectl apply -f dev-namespace.yml
```
- Запускаем приложение в dev-namespace
```
kubectl apply -n dev -f
```
- Добавляем информацию об окружении внутрь контейнера Ui и проверяем работу
```
kubectl apply -f ui-deployment.yml -n dev
```

## Работа c kubernetes
- Создаем кластер в GCE , подключаемся и создаем dev-namespace, разворачиваем наши приложения

```
kubectl apply -f ./kubernetes/reddit/dev-namespace.yml
kubectl apply -f ./kubernetes/reddit/ -n dev
```
- Создаем правило фаерволла, разрешаем доступ по портам 30000-32767
```
kubectl get nodes -o wide
NAME                                       STATUS   ROLES    AGE   VERSION         INTERNAL-IP   EXTERNAL-IP     OS-IMAGE                             KERNEL-VERSION   CONTAINER-RUNTIME
gke-cluster-1-default-pool-8c46a28e-lr5r   Ready    <none>   18m   v1.11.8-gke.6   10.132.0.12   34.76.165.70    Container-Optimized OS from Google   4.14.91+         docker://17.3.2
gke-cluster-1-default-pool-8c46a28e-md69   Ready    <none>   18m   v1.11.8-gke.6   10.132.0.13   23.251.130.14   Container-Optimized OS from Google   4.14.91+         docker://17.3.2
alexis@inkdev:~/inkdev_microservices/kubernetes/reddit$
alexis@inkdev:~/inkdev_microservices/kubernetes/reddit$
alexis@inkdev:~/inkdev_microservices/kubernetes/reddit$
alexis@inkdev:~/inkdev_microservices/kubernetes/reddit$
alexis@inkdev:~/inkdev_microservices/kubernetes/reddit$  kubectl describe service ui -n dev | grep NodePort
Type:                     NodePort
NodePort:                 <unset>  32092/TCP

```
- Заходим по вненешнему адресу, убеждаемся, что все работает
- Подключаем kubernetes dashboard. Включаем соответствующую опцию в конфигурации, стартуем proxy
```
kubectl proxy
Starting to serve on 127.0.0.1:8001

```
- По ссылке из руководства не заработало, поднялось только со ссылкой
http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy
Описание проблемы:https://github.com/kubernetes/dashboard/issues/3038 + на vps поднять ssh-туннель
- Настраиваем RBAC
Расширяем права cluster-admin
```
kubectl create clusterrolebinding kubernetes-dashboard  --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
```

### Задание с *
- Разворачиваем кластер с помощью Terraform. Необходимые файлы поместили в каталог kubernetes/terraform. Для развертывания приложения используем скрипт deploy.sh
Создали и проверили развертывание
```
terraform init
terraform init
terraform init
```
- Создали манифест dashboard-kubernetes.yml для включения дашбоарда kubernetes


### Домашнее задание №27(kubernetes-3)
Полезные команды
```
kubectl get services -n dev
```

Настройка LoadBalancer
- Меняем тип и порт подключения для loadbalancer
```
spec:
  type: LoadBalancer
  ports:
  - port: 80
    nodePort: 32092
    protocol: TCP
    targetPort: 9292
  selector:
    app: reddit
    component: ui
```
Проверка
```
 kubectl get service  -n dev --selector component=ui
NAME   TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)        AGE
ui     LoadBalancer   10.47.250.96   35.195.252.157   80:32092/TCP   21m

curl http://35.195.252.157
```

Ingress Controller
- Создаем Ingress для сервиса UI ui-ingress.yml
- Проверяем в кластере
```
kubectl get ingress -n dev
NAME   HOSTS   ADDRESS          PORTS   AGE
ui     *       35.244.192.207   80      3m
```

Установка Secret
Выпускаем сертификат, загружаем в kuber и проверяем
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=35.244.192.207"
kubectl create secret tls ui-ingress --key tls.key --cert tls.crt -n dev
 kubectl describe secret ui-ingress -n dev
Name:         ui-ingress
Namespace:    dev
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.key:  1708 bytes
tls.crt:  1111 bytes
```

### Задание со *
Опишем установку объекта Secret с помощью манифеста ui-ingress-secret.yml

Network policy
Получаем имя кластера
```
gcloud beta container clusters list
NAME       LOCATION        MASTER_VERSION  MASTER_IP       MACHINE_TYPE  NODE_VERSION  NUM_NODES  STATUS
cluster-1  europe-west1-c  1.11.8-gke.6    35.241.199.218  g1-small      1.11.8-gke.6  2          RUNNING
```
Включаем network-policy для gke
```
gcloud beta container clusters update cluster-1 --zone=europe-west1-c --update-addons=NetworkPolicy=ENABLED 
gcloud beta container clusters update cluster-1 --zone=europe-west1-c --enable-network-policy
```
Разворачиваем network-policy для mongo, обеспечиваем доступность post-сервиса до базы
```
- podSelector:
            matchLabels:
              app: reddit
              component: post
``` 
Хранилище для базы
- Подключаем volume через манифест mongo-deployment.yml
- Создаем пост в приложении
- Удаляем deployment mongo, пост исчез
- Применяем заново, создаем новый пост

Подключаем внешнее хранилище gcePersistentDisk
```
gcloud compute disks create --size=25GB --zone=europe-west1-c reddit-mongo-disk
```
- Объявляем в манифесте и пересоздаем mongo-deployment
- Пересоздаем Pod, создаем пост и удаляем deployment
- Снова создаем deployment, убеждаемся, что пост на месте

PersistentVolume
- Создаем манифест mongo-volume.yml
- Добавляем persistentVolume в кластер

PersistentVolumeClaim(запрос на выдачу ресурса)
- Создаем манифест mongo-claim
- Проверяем распределение pv
```
kubectl describe storageclass standard -n dev
Name:                  standard
IsDefaultClass:        Yes
Annotations:           storageclass.beta.kubernetes.io/is-default-class=true
Provisioner:           kubernetes.io/gce-pd
Parameters:            type=pd-standard
AllowVolumeExpansion:  <unset>
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     Immediate
Events:                <none>

```  
- Подключаем PVC к нашим подам

StorageClass
- Добавляем StorageClass в кластер
```
kubectl apply -f storage-fast.yml -n dev
```
- Создадим описание PersistentVolumeClaim
- Проверяем
```
  kubectl get persistentvolume -n dev
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                   STORAGECLASS   REASON   AGE
pvc-a5caeea6-7006-11e9-b759-42010a8401dd   15Gi       RWO            Delete           Bound       dev/mongo-pvc           standard                16m
pvc-b4faf4d5-7008-11e9-b759-42010a8401dd   10Gi       RWO            Delete           Bound       dev/mongo-pvc-dynamic   fast                    1m
reddit-mongo-disk                          25Gi       RWO            Retain           Available                                                   21m

```