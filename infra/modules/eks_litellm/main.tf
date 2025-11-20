locals {
  cluster_name = "${var.project_name}-${var.environment}-eks"
}

data "aws_iam_policy_document" "eks_cluster_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "${local.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy_document" "eks_node_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node" {
  name               = "${local.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  tags = var.tags
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.cluster_name}-ng"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.eks_node_min_size
    min_size     = var.eks_node_min_size
    max_size     = var.eks_node_max_size
  }

  instance_types = [var.eks_node_instance_type]

  tags = var.tags
}

data "aws_eks_cluster" "data" {
  name = aws_eks_cluster.this.name
}

data "aws_eks_cluster_auth" "auth" {
  name = aws_eks_cluster.this.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.data.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.data.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.auth.token
}

resource "kubernetes_namespace" "litellm" {
  metadata {
    name = "litellm"
    labels = {
      "app.kubernetes.io/name"      = "litellm"
      "app.kubernetes.io/component" = "gateway"
      "environment"                 = var.environment
    }
  }
}

resource "kubernetes_deployment" "litellm" {
  metadata {
    name      = "litellm-gateway"
    namespace = kubernetes_namespace.litellm.metadata[0].name
    labels = {
      app = "litellm-gateway"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "litellm-gateway"
      }
    }

    template {
      metadata {
        labels = {
          app = "litellm-gateway"
        }
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "4000"
        }
      }

      spec {
        container {
          name  = "litellm"
          image = "ghcr.io/berriai/litellm:latest"

          port {
            container_port = 4000
          }

          env {
            name  = "LITELLM_CONFIG"
            value = "/app/config.yaml"
          }

          resources {
            requests {
              cpu    = "250m"
              memory = "512Mi"
            }
            limits {
              cpu    = "500m"
              memory = "1Gi"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 4000
            }
            initial_delay_seconds = 20
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 4000
            }
            initial_delay_seconds = 10
            period_seconds        = 15
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "litellm" {
  metadata {
    name      = "litellm-gateway"
    namespace = kubernetes_namespace.litellm.metadata[0].name
    labels = {
      app = "litellm-gateway"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = "litellm-gateway"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 4000
    }
  }
}

output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "service_name" {
  value = "${kubernetes_service.litellm.metadata[0].name}.${kubernetes_namespace.litellm.metadata[0].name}.svc.cluster.local"
}
