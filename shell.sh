docker exec -it `docker container ls | grep ubuntu-mate-rdp | cut -f 1 -d " "` /bin/bash
