DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PASS=$1
DOMAIN=${2:-talk.hackspace.ca}
SELECTOR=${3:-default}
docker run -e "domain=$DOMAIN" -e "selector=$SELECTOR" -e "passwd=$PASS" -d -p 110:110 -p 25:25 -v $DIR/log:/var/log/supervisor -v $DIR/mail:/var/mail -v $DIR/home:/home --name discourse_mail hackspace/discourse_mail
