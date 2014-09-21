DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PASS=$1
DOMAIN=${2:-talk.hackspace.ca}
SELECTOR=${3:-default}
echo "Building"
docker build -t hackspace/discourse_mail $DIR

echo "Stopping existing instance"
docker stop discourse_mail

echo "Removing old instance"
docker rm discourse_mail

echo "Starting"
docker run -e "domain=$DOMAIN" -e "selector=$SELECTOR" -e "passwd=$PASS" -d -p 110:110 -p 25:25 -v $DIR/log:/var/log/supervisor -v $DIR/mail:/var/mail -v $DIR/home:/home --name discourse_mail hackspace/discourse_mail
