resource "random_password" "password" {
  length = 24
  special = true
  override_special = "_%@"
}

locals {
    connection_string = "mongo mongodb://'${var.host1_ip}','${var.host2_ip}','${var.host3_ip}'/?authSource=admin&replicaSet=rs0"
}

data "template_file" "init_inventory" {
  template = "${file("terraform_templates/hosts_template")}"
  vars = {
    host1_ip = "${var.host1_ip}"
    host2_ip = "${var.host2_ip}"
    host3_ip = "${var.host3_ip}"
  }
}

resource "local_file" "hosts" {
    content     = data.template_file.init_inventory.rendered
    filename = "hosts"
}

data "template_file" "group_vars_template" {
  template = "${file("terraform_templates/group_vars_template")}"
  vars = {
    host1_ip = "${var.host1_ip}"
    host2_ip = "${var.host2_ip}"
    host3_ip = "${var.host3_ip}"
    random_password = "${random_password.password.result}"
  }
}

resource "local_file" "group_vars_template" {
    content     = data.template_file.group_vars_template.rendered
    filename = "group_vars/all.yml"
}

data "template_file" "password_template" {
  template = "${file("terraform_templates/credentials_template")}"
  vars = {
    host1_ip = "${var.host1_ip}"
    host2_ip = "${var.host2_ip}"
    host3_ip = "${var.host3_ip}"
    random_password = "${random_password.password.result}"
  }
}

resource "local_file" "password_template" {
    content     = data.template_file.password_template.rendered
    filename = "credentials.passwd"
}

data "template_file" "initRS" {
  template = "${file("terraform_templates/initRS_template")}"
  vars = {
    host1_ip = "${var.host1_ip}"
    host2_ip = "${var.host2_ip}"
    host3_ip = "${var.host3_ip}"
  }
}

resource "null_resource" "keyFile" {
  provisioner "local-exec" {
    command = "openssl rand -base64 258 > roles/mongodb/templates/keyfile.j2"
  }
}

resource "local_file" "initRS" {
    content     = data.template_file.initRS.rendered
    filename = "roles/mongodb/templates/initRS.j2"
}

resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook --limit mongo_cluster main.yml"
  }
}

resource "null_resource" "del_tfstate" {
  provisioner "local-exec" {
    command = "./terraform_templates/delete_files.sh"
  }
    depends_on = [null_resource.ansible]
}