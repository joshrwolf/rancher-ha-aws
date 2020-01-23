module "ssh-key" {
  source = "../ssh-key"
  name = "rancher-management"
  output_folder = "${path.root}/outputs/"
}

resource "aws_security_group" "rancher" {
  name = "${local.name}-rancher-management-server"
  vpc_id = local.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    security_groups = local.ssh_security_group_ids
  }

  ingress {
    description = "http access"
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https access"
    from_port = 443
    to_port = 443
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "kube-api access"
    from_port = 6443
    to_port = 6443
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "traffic between self"
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  egress {
    description = "egress traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//Required Nodes
resource "aws_instance" "rancher-master" {
  count = local.master_node_count
  ami = local.ami_id
  instance_type = local.instance_type
  key_name = module.ssh-key.aws_key_id

  user_data = templatefile("${path.module}/files/cloud-config.template.yaml", {})

  vpc_security_group_ids = [aws_security_group.rancher.id]
  subnet_id = element(tolist(local.rancher2_master_subnet_ids), 0)
  associate_public_ip_address = false

  root_block_device {
    volume_type = "gp2"
    volume_size = "50"
  }

  tags = merge({
    Name = "${local.name}-rancher-management-master-${count.index}"
  }, local.rancher2_master_tags)
}

//resource "aws_launch_template" "rancher_master" {
//  name_prefix = "${local.name}-rancher-management-master"
//  image_id = data.aws_ami.ubuntu.image_id
//  instance_type = local.instance_type
//  key_name = aws_key_pair.ssh.id
//
//  block_device_mappings {
//    device_name = "/dev/sda1"
//
//    ebs {
//      encrypted = "true"
//      volume_type = "gp2"
//      volume_size = "50"
//    }
//  }
//
//  network_interfaces {
//    associate_public_ip_address = false
//    delete_on_termination = true
//    security_groups = [aws_security_group.rancher.id]
//  }
//
//  tags = merge({
//    Name = "${local.name}-rancher-management-master",
//  }, local.rancher2_master_tags)
//
//  tag_specifications {
//    resource_type = "instance"
//
//    tags = merge({ Name = "${local.name}-rancher-management-master" }, local.rancher2_master_tags)
//  }
//}
//
//resource "aws_autoscaling_group" "rancher_master" {
//  min_size = local.master_node_count
//  max_size = local.master_node_count
//  desired_capacity = local.master_node_count
//
//  vpc_zone_identifier = local.rancher2_master_subnet_ids
//
////  load_balancers = [aws_elb.rancher.name]
//
//  load_balancers = [aws_lb.rancher_api.name]
//
//  launch_template {
//    id = aws_launch_template.rancher_master.id
//    version = "$Latest"
//  }
//}

//Load balancers for API and web app
//resource "aws_security_group" "rancher-elb" {
//  name = "${local.name}-rancher-elb"
//  vpc_id = local.vpc_id
//
//  ingress {
//    from_port = 80
//    to_port = 80
//    protocol = "TCP"
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//
//  ingress {
//    from_port = 443
//    to_port = 443
//    protocol = "TCP"
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//
//  egress {
//    from_port = 0
//    to_port = 0
//    protocol = "-1"
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//}
//
//resource "aws_elb" "rancher" {
//  name = "${local.name}-rancher-elb"
//  subnets = local.aws_elb_subnet_ids
//  security_groups = [aws_security_group.rancher-elb.id]
//
//  listener {
//    instance_port = 80
//    lb_port = 80
//    instance_protocol = "tcp"
//    lb_protocol = "tcp"
//  }
//
//  listener {
//    instance_port = 443
//    lb_port = 443
//    instance_protocol = "tcp"
//    lb_protocol = "tcp"
//  }
//
//  health_check {
//    healthy_threshold = 2
//    interval = 5
//    target = "tcp:80"
//    timeout = 2
//    unhealthy_threshold = 2
//  }
//
//  instances = null
//  idle_timeout = 1800
//
//  tags = local.rancher2_master_tags
//}

resource "aws_lb" "rancher" {
  name = "${local.name}-rancher-nlb"
  internal = false
  load_balancer_type = "network"
  subnets = local.aws_elb_subnet_ids

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  tags = local.rancher2_master_tags
}

//resource "aws_lb_listener" "rancher_api_https" {
//  load_balancer_arn = aws_lb.rancher.arn
//  port = "6443"
//  protocol = "TCP"
//
//  default_action {
//    type = "forward"
//    target_group_arn = aws_lb_target_group.rancher_api.arn
//  }
//}
//
//resource "aws_lb_target_group" "rancher_api" {
//  name = "${local.name}-rancher-api-tg"
//  port = 6443
//  protocol = "TCP"
//  vpc_id = local.vpc_id
//
////  health_check {
////    healthy_threshold = 2
////    unhealthy_threshold = 2
////    timeout = 10
////    interval = 30
////    port = "6443"
////  }
//}
//
////Create a target group attachment for each instance
//resource "aws_lb_target_group_attachment" "rancher_api" {
//  count = length(aws_instance.rancher-master.*.id)
//
//  target_group_arn = aws_lb_target_group.rancher_api.arn
//  target_id = aws_instance.rancher-master[count.index].id
//}

resource "aws_lb_listener" "rancher_web_https" {
  load_balancer_arn = aws_lb.rancher.arn
  port = "443"
  protocol = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.rancher_web_https.arn
  }
}

resource "aws_lb_target_group" "rancher_web_https" {
  name = "${local.name}-rancher-web-https-tg"
  port = 443
  protocol = "TCP"
  vpc_id = local.vpc_id

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 3
    timeout = 6
    interval = 10
    port = "80"
    protocol = "HTTP"
    path = "/healthz"
  }
}

//Create a target group attachment for each instance
resource "aws_lb_target_group_attachment" "rancher_web_https" {
  count = length(aws_instance.rancher-master.*.id)

  target_group_arn = aws_lb_target_group.rancher_web_https.arn
  target_id = aws_instance.rancher-master[count.index].id
}

resource "aws_lb_listener" "rancher_web_http" {
  load_balancer_arn = aws_lb.rancher.arn
  port = "80"
  protocol = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.rancher_web_http.arn
  }
}

resource "aws_lb_target_group" "rancher_web_http" {
  name = "${local.name}-rancher-web-http-tg"
  port = 80
  protocol = "TCP"
  vpc_id = local.vpc_id

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 3
    timeout = 6
    interval = 10
    protocol = "HTTP"
    path = "/healthz"
  }
}

//Create a target group attachment for each instance
resource "aws_lb_target_group_attachment" "rancher_web_http" {
  count = length(aws_instance.rancher-master.*.id)

  target_group_arn = aws_lb_target_group.rancher_web_http.arn
  target_id = aws_instance.rancher-master[count.index].id
}


//S3 storage for etcd backups on all the clusters
resource "aws_s3_bucket" "etcd_backups" {
  bucket = "${local.name}-rancher-etcd-backup"
  acl = "private"

  versioning {
    enabled = true
  }
}

resource "aws_iam_user" "etcd_backup_user" {
  name = "${local.name}-etcd-backup"
}

resource "aws_iam_access_key" "etcd_backup_user" {
  user = aws_iam_user.etcd_backup_user.name
}

resource "aws_iam_user_policy" "etcd_backup_user" {
  name = "${aws_iam_user.etcd_backup_user.name}-policy"
  user = aws_iam_user.etcd_backup_user.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "etcdBackupBucket",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:DeleteObject"
      ],
      "Resource": [
        "${aws_s3_bucket.etcd_backups.arn}",
        "${aws_s3_bucket.etcd_backups.arn}/*"
      ]
    }
  ]
}
EOF

}