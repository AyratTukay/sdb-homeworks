
# создаём виртуальную машину на яндекс клоуд
variable hostname_blocks {}
variable name_blocks {}
variable images_blocks {}
variable cores_blocks {}
variable memory_blocks {}
variable core_fraction_blocks {}

variable count_vm {}

#------ vms ---------
resource "yandex_compute_instance" "vm" {
  
  count = "${var.count_vm}"

  name = "${var.name_blocks[count.index]}"
  hostname = "${var.hostname_blocks[count.index]}"

  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = "ru-central1-a"

  resources {
    core_fraction = "${var.core_fraction_blocks[count.index]}"
    cores  = "${var.cores_blocks[count.index]}"
    memory = "${var.memory_blocks[count.index]}"
  }
 
  boot_disk {
    initialize_params {
        image_id = "${var.images_blocks[count.index]}"
        size = 16
    }
  }
 
  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data = "${file("cloud-init.yml")}"
  }

  #----------------создаём папки--------------

  provisioner "remote-exec" {
    inline = [
        "cd ~",
        "mkdir -pv configs",
        "mkdir -pv docker_volumes",
        "mkdir -pv docker_volumes/elasticsearch",
        "mkdir -pv configs/elasticsearch",
        "mkdir -pv configs/filebeat",
        "mkdir -pv configs/kibana",
        "mkdir -pv configs/logstash",
        "mkdir -pv configs/logstash/pipelines"
     ]
  }

  #----------------копируем файлы--------------

  provisioner "file" {
    source = "./docker-compose.yml"
    destination = "./docker-compose.yml"
  }

  provisioner "file" {
    source = "./configs/elasticsearch/config.yml"
    destination = "./configs/elasticsearch/config.yml"
  }

  provisioner "file" {
    source = "./configs/filebeat/config.yml"
    destination = "./configs/filebeat/config.yml"
  }

  provisioner "file" {
    source = "./configs/kibana/config.yml"
    destination = "./configs/kibana/config.yml"
  }

  provisioner "file" {
    source = "./configs/logstash/config.yml"
    destination = "./configs/logstash/config.yml"
  }

  provisioner "file" {
    source = "./configs/logstash/pipelines/service_stamped_json_logs.conf"
    destination = "./configs/logstash/pipelines/service_stamped_json_logs.conf"
  }
  
   provisioner "file" {
    source = "./configs/logstash/pipelines.yml"
    destination = "./configs/logstash/pipelines.yml"
  }
    
  #---------------------------------------------------------------
 
  provisioner "remote-exec" {
    inline = [
        "sudo apt update",
        "sudo apt install -y ca-certificates curl",
        "sudo install -m 0755 -d /etc/apt/keyrings",
        "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.gpg",
        "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
 #       "echo \"deb [arch=\"$(dpkg --print-architecture)\" signet-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu",
 #       "sudo wget https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64&_gl=1*pixgdr*_gcl_au*MzQ1NjM3NDYyLjE3NjgwNjg5OTI.*_ga*MjI1NjY1OTIyLjE3Njc4OTc1NDc.*_ga_XJWPQMJYHQ*czE3NjkzMjczMTEkbzEzJGcxJHQxNzY5MzMwMTM3JGo1OSRsMCRoMA..",
        "sudo apt update",
        "curl -fsSL https://get.docker.com -o get-docker.sh",
        "sudo sh get-docker.sh",
        "sudo chmod +x ./docker-compose.yml",
        "chmod go-w /usr/share/filebeat/config.yml",
        "sudo chmod 777 /var/run/docker.sock",
        "sudo systemctl start docker",
        "sudo apt update",
        "sudo apt install -y nginx",
        "sudo chmod 777 /var/log/nginx/access.log",
        "sudo curl localhost",
        "sudo docker compose up -d"
     ]
  }
  
  connection {
    type = "ssh"
    user = "ayrat"
    host = self.network_interface[0].nat_ip_address
  }
}
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}
resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}