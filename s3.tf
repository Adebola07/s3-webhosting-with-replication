variable "bucket-name" {
  description = "value"
  type = string 
  default = "zamani-07"
}

module "template_file" {
  source = "hashicorp/dir/template"
  base_dir = "${path.module}/web"
}


resource "aws_s3_bucket" "zamani_07" {
  bucket = var.bucket-name
}

resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.zamani_07.id 

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "control_list" {
  bucket = aws_s3_bucket.zamani_07.id
  acl = "public-read"
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.zamani_07.id 
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": ["s3:GetObject", "s3:PutObject"], 
            "Resource": "arn:aws:s3:::${var.bucket-name}/*"
        }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.zamani_07.id 
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "objects" {
  bucket = aws_s3_bucket.zamani_07.id 
  for_each = module.template_file.files
  key = each.key
  content_type = each.value.content_type 

  source = each.value.source_path 
  content = each.value.content 

  etag = each.value.digests.md5 

  depends_on = [aws_s3_bucket_versioning.example]
}

resource "aws_s3_bucket_ownership_controls" "owner" {
  bucket = aws_s3_bucket.zamani_07.id 
  rule {
    object_ownership = "BucketOwnerPreferred" 
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.zamani_07.id 

  block_public_acls = false 
  block_public_policy = false 
  ignore_public_acls = false 
  restrict_public_buckets = false 
}

output "website_url" {
  description = "website url"
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}