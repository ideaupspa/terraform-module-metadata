module "example_implementation" {
  source      = "../module"
  namespace   = "mynamespace"
  environment = "development"
  stage       = "build"
  name        = "Example Application"
  delimiter   = "_"
  
  label_order = [
	"name" ,
	"environment" ,
	"stage" ,
	"attributes" ]
  
  tags = {
	"Repo"  = "git:some_repo"
	"Owner" = "Me"
  }
}