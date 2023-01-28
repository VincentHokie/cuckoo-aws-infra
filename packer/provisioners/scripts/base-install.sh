sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install uwsgi uwsgi-plugin-python nginx uwsgi-core -y

sudo touch /etc/nginx/sites-available/cuckoo-web
sudo touch /etc/uwsgi/apps-available/cuckoo-web.ini
sudo touch /etc/nginx/snippets/self-signed.conf
sudo touch /etc/nginx/snippets/ssl-params.conf
sudo touch /etc/uwsgi/apps-available/cuckoo-api.ini
sudo touch /etc/nginx/sites-available/cuckoo-api

sudo chmod 777 /etc/nginx/sites-available/cuckoo-web
sudo chmod 777 /etc/uwsgi/apps-available/cuckoo-web.ini
sudo chmod 777 /etc/nginx/snippets/self-signed.conf
sudo chmod 777 /etc/nginx/snippets/ssl-params.conf
sudo chmod 777 /etc/uwsgi/apps-available/cuckoo-api.ini
sudo chmod 777 /etc/nginx/sites-available/cuckoo-api