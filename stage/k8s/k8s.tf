terraform {
  backend "azurerm" {
    resource_group_name   = "core"
    storage_account_name  = "corestorageaccforlab"
    container_name        = "terraform-dev-state"
    key                   = "terraform-aks-hyphen.tfstate"
  }
}


data "azurerm_kubernetes_cluster" "aks" {
  name                = "tf-k8s"
  resource_group_name = "tf-k8s-resources"
}

provider "kubernetes" {
    host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}


resource "kubernetes_namespace" "app" {
  metadata {
    name = "hyphen"
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = "hyphen-app"
    namespace = kubernetes_namespace.app.metadata.0.name
    labels = {
      app = "hyphen-app"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "hyphen-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "hyphen-app"
        }
      }

      spec {
        container {
          image = "jeewansoori/hyphen-app"
          name  = "hyphen-app"
          
          port {
            container_port = 5000
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "128Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name = "app-service"
    namespace = kubernetes_namespace.app.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.app.metadata.0.labels.app
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      target_port = 5000
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress" "app" {
  metadata {
    name = "web-ingress"
    namespace = kubernetes_namespace.app.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
    }
  }

  spec {
    rule {
      http {
        path {
          backend {
            service_name = kubernetes_service.app.metadata.0.name
            service_port = 80
          }

          path = "/hyphen(/|$)(.*)"
        }

      }
    }
  }
}