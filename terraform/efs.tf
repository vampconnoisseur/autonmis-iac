resource "aws_security_group" "efs_sg" {
  name        = "autonmis-efs-mount-target-sg"
  description = "Security group for EFS mount targets"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EFS-Mount-Target-SG"
  }
}

resource "aws_efs_file_system" "autonmis-efs" {
  creation_token = "airflow-efs"
  tags = {
    Name = "autonmis-efs-fs"
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count           = length(module.vpc.private_subnets)
  file_system_id  = aws_efs_file_system.autonmis-efs.id
  subnet_id       = module.vpc.private_subnets[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}
