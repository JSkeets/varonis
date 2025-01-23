# Assumptions
- I assumed that a VPC already exist for the "production" machine, as well as private subnets, and additionally that the resources within the VPC are tagged in a way that makes them searchable. (i.e. private subnets are tagged with "Private")
- We know the private IP address of the "production" machine and the IP address of the "quality" machine from the external data center
- All resources -- ECR, PDF service, and the "production" machine are in the same AWS account and region.
- I assumed that terraform state management (dynamodb and s3) is already configured within the AWS account, my code does not create these resources. -- For the simplicity of this assignment I used local state, but would not do so in a production environment.
- I recognize that cloudwatch logging is important, but felt it was out of scope for this challenge.
- AWS account credentials are configured within your environment

# Approach
- I believe minimal and serverless alleviates a lot of burden, especially for a small infrastructure team. I elected to use lambdas behind an API Gateway. I believe the situations in which we would want to use a self hosted solution (EC2, or ECS EC2) would likely be to do some very strict security requirements where single tenant is required.

- I elected to have a public facing API gateway, an alternative would be to have a site-to-site VPN and a private API gateway, but I believe this increases complexity and cost, with little benefit. The API gateway only allows traffic from our allow-listed CIDR block (non aws data center, and our "production" machine private IP address). The lambdas have no security group ingress and egress rules and rely on IAM policies to allow access from the API gateway.

- I believe terraform modules should truly be as modular and generic as possible, this makes it easier to reuse these modules for other projects.

# AI Usage
 - I used Claude 3.5 via Cursor to generate much of the boilerplate terraform (variables, outputs, data), and used ChatGPT as a sounding board for ideas that I had, like a rubber duck.

 # Future Improvements
 - Work could be done, closely with the developer to structure the response error codes and messages of the API Gateway, as well as limiting request body types and sizes.
 - I would containerize the infrastructure deployment and create a shell script which execs into the container, so that if others run the terraform locally it will be on the same version, and the reduce the complexity for others to get up to speed.
 - The lambda creation fails in this current terraform setup because there is no docker image in the ECR repository. This could be rectified as part of a CI process, and different terraform apply steps, or including the containers as part of this repository.
 - I recognize that the lambda may pose some problems if the API is not hit frequently due to cold start times, this would require a discussion regarding frequency of use of the API, or some sort of keep alive mechanism.
 
 # Running the terraform
 - Ensure you have AWS CLI installed, and are authenticated
 - Ensure you have Terraform installed, this was run using version "v1.10.1"
 - Navigate to environment/us-east-1/dev
 - terraform init
 - terraform apply --var-file=dev.tfvars

