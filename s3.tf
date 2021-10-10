# S3 bucket for wordpress static files
resource "aws_s3_bucket" "s3_bucket_static" {
  bucket        = "${var.project}-${var.env}-static"
  acl           = "public-read"
  force_destroy = false

  tags = {
    Project     = "${var.project}"
    Environment = "${var.env}"
    Name        = "${var.project}-${var.env}-static"
  }

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Id": "Policy1410256987704",
  "Statement": [
    {
      "Sid": "Stmt1410256977473",
      "Effect": "Allow",
      "Principal": {
          "AWS": "*"
          },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.project}-${var.env}-static/*"
    }
  ]
}
EOF
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
