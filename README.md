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






