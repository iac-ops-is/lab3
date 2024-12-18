# **Django Application Deployment with Nginx and Roles**

This project demonstrates how to deploy a Django application using Nginx for serving static files and reverse proxying requests, leveraging Ansible roles for automation. By completing this project, you will learn how to create templates for Nginx configuration and manage multi-host deployments with Vagrant and Docker.

---

## **Objective**

- Deploy a Django application using Nginx for handling static files and acting as a reverse proxy.
- Automate the deployment using Ansible roles.
- Learn how to template configurations dynamically.
- Use Docker for containerizing the Django application.

---

## **Prerequisites**

- Basic knowledge of Vagrant, Ansible, and Docker.
- Installed software:
  - [Vagrant](https://www.vagrantup.com/)
  - [VirtualBox](https://www.virtualbox.org/)
  - [Ansible](https://docs.ansible.com/)
  - [Docker](https://www.docker.com/)

---

## **Repository Details**

- **Django Application Source:** [MDN Django Local Library Tutorial](https://github.com/mdn/django-locallibrary-tutorial)
- **Docker Image:** [timurbabs/django](https://hub.docker.com/repository/docker/timurbabs/django)

---

## **Setup Steps**

### **1. Launch Vagrant Environment**

1. Clone this repository:
   ```bash
   git clone https://github.com/your-repo/project-name.git
   cd project-name
   ```

2. Launch the Vagrant environment:
   ```bash
   vagrant up
   ```

This will set up two VMs:

Web Host (Nginx): 192.168.56.201
App Host (Docker): 192.168.56.202
The provisioning script will install Python and configure SSH keys for Ansible access.

2. Create Nginx Role
Navigate to the roles/directory:
```
mkdir -p roles/nginx/{tasks,templates,defaults}
```

3. Write the Nginx role:

roles/nginx/tasks/main.yml:

```
- name: Install Nginx
  ansible.builtin.apt:
    name: nginx
    state: present

- name: Deploy Nginx configuration
  ansible.builtin.template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: '0644'
    validate: /usr/sbin/nginx -t -c %s
    backup: yes

- name: Restart Nginx
  ansible.builtin.service:
    name: nginx
    state: restarted
    enabled: true
```

roles/nginx/templates/nginx.conf.j2:
```
user  {{ nginx_user }};
worker_processes  {{ nginx_worker_processes }};
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections {{ nginx_worker_connections }};
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    sendfile on;
    keepalive_timeout  65;

    server {
        listen 80;
        server_name _;

        location /static/ {
            root {{ static_files_root }};
            try_files $uri $uri/ =404;
        }

        location / {
            proxy_pass http://{{ proxy_pass_target }};
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    upstream app_servers {
        {% for host in groups['app'] %}
        server {{ host }}:8000;
        {% endfor %}
    }
}
```

roles/nginx/defaults/main.yml:
```
nginx_user: "www-data"
nginx_worker_processes: 2
nginx_worker_connections: 1024
static_files_root: "/var/www/static"
proxy_pass_target: "app_servers"
```

3. Write the Inventory File
Prepare the inventory file to define hosts:

inventory/hosts.ini

```
[web]
192.168.56.201

[app]
192.168.56.202
```

4. Write the Playbook
Write the Ansible playbook for deploying Nginx and Docker.

5. Launch Application
Run the playbook:
```
ansible-playbook -i inventory/hosts.ini playbook.yml
```

Access the application:

Static files served via Nginx: http://192.168.56.201/static/
Django application via reverse proxy: http://192.168.56.201/

6. Additional Notes
Ensure the nginx.conf template has proper permissions:

```bash
chmod 0644 roles/nginx/templates/nginx.conf.j2
```
Validate your Ansible syntax before running the playbook:

```bash
ansible-playbook playbook.yml --check
```
To destroy the Vagrant environment:

```bash
vagrant destroy -f
```

Conclusion
This project demonstrates a complete pipeline for deploying a Django application with Nginx and Docker, showcasing templated configurations and automation using Ansible roles. By following this guide, you will gain hands-on experience in deploying modern web applications in multi-host environments.