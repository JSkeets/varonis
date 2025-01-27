# Prerequisites
- Github actions configured with AWS credentials
- If running locally, ensure AWS CLI and Terraform are installed.

# Approach
- I elected to use AWS, because I am ultimately more familiar with it, and wanted to focus on the architecture and solution instead of implementation in Azure.
- The entire solution is serverless and scalable, requiring little to no maintenance. All resources are hosted within a VPC to ensure networking privacy. 