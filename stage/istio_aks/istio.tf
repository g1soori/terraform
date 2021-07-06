resource "null_resource" "istio" {
    depends_on = [helm_release.nginx_ingress]

    # triggers = {
    #     manifest_sha1 = "${sha1("${data.template_file.your_template.rendered}")}"
    # }

    provisioner "local-exec" {
        command = "az aks get-credentials --resource-group ${azurerm_resource_group.aks.name} --overwrite-existing --name ${azurerm_kubernetes_cluster.aks.name}"
    }
    
    provisioner "local-exec" {
        command = "kubectl create -f warmup-exercise/1-istio-init.yaml"
    }

    provisioner "local-exec" {
        command = "kubectl create -f warmup-exercise/2-istio-minikube.yaml"
    }

    provisioner "local-exec" {
        command = "kubectl create -f warmup-exercise/3-kiali-secret.yaml"
    }

    provisioner "local-exec" {
        command = "kubectl label namespace default istio-injection=enabled"
    }
    
    provisioner "local-exec" {
        command = "kubectl create -f warmup-exercise/4-application-full-stack.yaml"
    }

    provisioner "local-exec" {
        command = "bash warmup-exercise/port-forward.sh "
    }

    
}

resource "kubernetes_ingress" "app" {
  depends_on = [
    null_resource.istio
  ]

  metadata {
    name = "web-ingress"
    namespace = "default"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    rule {
      http {
        path {
          backend {
            service_name = "fleetman-webapp"
            service_port = 80
          }

        #   path = "/istio(/|$)(.*)"
          path = "/"
        }
      }
    }
  }
}

resource "kubernetes_ingress" "istio" {
  depends_on = [
    null_resource.istio
  ]

  metadata {
    name = "kiali-ingress"
    namespace = "istio-system"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      # "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      # "nginx.ingress.kubernetes.io/app-root" = "/"
    }
  }

  spec {
    rule {
      http {
        path {
          backend {
            service_name = "kiali"
            service_port = 20001
          }

        #   path = "/istio(/|$)(.*)"
          path = "/kiali"
        }
      }
    }
  }
}