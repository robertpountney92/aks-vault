output "vault_lb_endpoint" {
  value = "http://${data.kubernetes_service.vault_lb.load_balancer_ingress[0].ip}:8200"
}



