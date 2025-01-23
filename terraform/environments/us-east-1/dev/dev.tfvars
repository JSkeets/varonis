service       = "restaurant"
environment   = "dev"
region        = "us-east-1"
vpc_name      = "foodtrails-dev-vpc"
allowed_cidrs = [
  "0.0.0.0/0"     # "Production" Machine Private IP Address
]

