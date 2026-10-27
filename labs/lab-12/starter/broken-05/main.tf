# Module errors (4)
module "api" {
  source  = "modules/svc"
  name    = "api"
  version = "1.0.0"
}

module "web" {
  source   = "./modules/svc"
  name     = "web"
  port     = 80
  protocol = "http"
}

output "api_url" {
  value = module.api.url
}
