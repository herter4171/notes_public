resource "aws_s3_bucket" "wp-backup-2676" {
  bucket = "wp-backup-2676"
  acl = "private"

  tags = {
    Name = "wp-backup-2676"
  }
}

resource "aws_s3_bucket_policy" "wp_s3_policy" {
  bucket = aws_s3_bucket.wp-backup-2676.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "wp-policy",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      
      "Principal": {
          "AWS": "arn:aws:iam::821856822529:user/herter"
      },

      "Resource": [
          "arn:aws:s3:::wp-backup-2676",
          "arn:aws:s3:::wp-backup-2676/*"
      ]
    }
  ]
}
POLICY
}