# Prerequisites
- Github actions configured with AWS credentials
- If running locally, ensure AWS CLI and Terraform are installed.

# Approach
- I elected to use AWS, because I am ultimately more familiar with it, and wanted to focus on the architecture and solution instead of implementation in Azure.
- The entire solution is serverless and scalable, requiring little to no maintenance. All resources are hosted within a VPC to ensure networking privacy. 
- The approach is fairly complete, it features logging, alerting, and a github actions pipeline which deploys changes either to the api service or to the lambda function.

# Assumptions
- The prompt stated that we should reseed the dynamoDB if we add or modify new restaurants, so that functionality exists in the code base with seed data, but please note that we also state that this data is highly confidential, and I would never commit confidential data to github.
- I would also never host any production code in a public github, for ease of sharing my solution I have done so, but just want to be explicit about this.

# To deploy
- Assuming you have this in your own github and have forked the repo it is as simple as running the `master-deploy` workflow. If you wish to run it manually
- 
