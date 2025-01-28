# Prerequisites
- Github account, configure AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in the repo settings under environment secrets


# Approach
- I elected to use AWS, because I am ultimately more familiar with it, and wanted to focus on the architecture and solution instead of implementation in Azure.
- The entire solution is serverless and scalable, requiring little to no maintenance. All resources are hosted within a VPC to ensure networking privacy. 
- The approach is fairly complete, it features logging, alerting, and a github actions pipeline which deploys changes either to the api service or to the lambda function, future improvements could include some testing library within the API service, we could also add some security scanning such as `tfsec` within the pipeline to check for security best practices.

# Assumptions
- The prompt stated that we should reseed the dynamoDB if we add or modify new restaurants, so that functionality exists in the code base with seed data, but please note that we also state that this data is highly confidential, and I would never commit confidential data to github.
- I would also never host any production code in a public github, for ease of sharing my solution I have done so, but just want to be explicit about this.

# To deploy
- Run the `master-deploy` workflow, this will create the terraform state resource (S3 and dynamodb), bootstrap the infrastructure, push a container to the registry, apply the terraform, seed the dynamoDB, and deploy the api. 
