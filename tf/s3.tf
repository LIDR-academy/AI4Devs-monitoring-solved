resource "aws_s3_bucket" "code_bucket" {
  bucket = "lti-project-code-bucket"
  acl    = "private"
}

resource "null_resource" "generate_zip" {
  provisioner "local-exec" {
    command = "sh ../generar-zip.sh"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "aws_s3_bucket_object" "backend_zip" {
  bucket     = aws_s3_bucket.code_bucket.bucket
  key        = "backend.zip"
  source     = "../backend.zip"
  depends_on = [null_resource.generate_zip]
}

resource "aws_s3_bucket_object" "frontend_zip" {
  bucket     = aws_s3_bucket.code_bucket.bucket
  key        = "frontend.zip"
  source     = "../frontend.zip"
  depends_on = [null_resource.generate_zip]
}
