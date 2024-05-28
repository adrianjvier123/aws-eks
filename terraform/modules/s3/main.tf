resource "aws_s3_bucket" "my_bucket_static" { #s3 para tfstate

  bucket = "${var.bucket_wp_name}-s3"  #Enter unique name here
  tags = {
    Name        = "My bucket"
  }
}
resource "null_resource" "remove_and_upload_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 sync ../modules/s3/manifest/ s3://${aws_s3_bucket.my_bucket_static.id}/path/"
  }
}
