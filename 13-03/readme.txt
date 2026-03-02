sudo apt install suricata
sudo suricata-update
sudo nano /etc/suricata/suricata.yaml
sudo suricata -c /etc/suricata/suricata.yaml -i enp0s3
sudo tail -f /var/log/suricata/fast.log

sudo apt install fail2ban
sudo systemctl status fail2ban
sudo cat /var/log/auth.log
