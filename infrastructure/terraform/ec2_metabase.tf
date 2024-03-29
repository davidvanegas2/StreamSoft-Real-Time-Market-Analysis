resource "aws_iam_role" "ec2_role" {
  name = "ec2_metabase_role"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
          Action = "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_metabase_instance_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy" "ec2_metabase_policy" {
  name = "ec2_metabase_policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "Athena",
          "Effect" : "Allow",
          "Action" : [
            "athena:BatchGetNamedQuery",
            "athena:BatchGetQueryExecution",
            "athena:GetNamedQuery",
            "athena:GetQueryExecution",
            "athena:GetQueryResults",
            "athena:GetQueryResultsStream",
            "athena:GetWorkGroup",
            "athena:ListDatabases",
            "athena:ListDataCatalogs",
            "athena:ListNamedQueries",
            "athena:ListQueryExecutions",
            "athena:ListTagsForResource",
            "athena:ListWorkGroups",
            "athena:ListTableMetadata",
            "athena:StartQueryExecution",
            "athena:StopQueryExecution",
            "athena:CreatePreparedStatement",
            "athena:DeletePreparedStatement",
            "athena:GetPreparedStatement"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "Glue",
          "Effect" : "Allow",
          "Action" : [
            "glue:BatchGetPartition",
            "glue:GetDatabase",
            "glue:GetDatabases",
            "glue:GetPartition",
            "glue:GetPartitions",
            "glue:GetTable",
            "glue:GetTables",
            "glue:GetTableVersion",
            "glue:GetTableVersions"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "S3ReadAccess",
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:ListBucket",
            "s3:GetBucketLocation"
          ],
          "Resource" : [
            aws_s3_bucket.lakehouse_bucket.arn,
            "${aws_s3_bucket.lakehouse_bucket.arn}/*",
            aws_s3_bucket.resources_bucket.arn,
            "${aws_s3_bucket.resources_bucket.arn}/*"
          ]
        },
        {
          "Sid" : "AthenaResultsBucket",
          "Effect" : "Allow",
          "Action" : [
            "s3:PutObject",
            "s3:GetObject",
            "s3:AbortMultipartUpload",
            "s3:ListBucket",
            "s3:GetBucketLocation"
          ],
          "Resource" : [
            aws_s3_bucket.resources_bucket.arn,
            "${aws_s3_bucket.resources_bucket.arn}/*"
          ]
        }
      ]
    }
  )
}

resource "aws_security_group" "metabase_sg" {
  name        = "metabase_sg"
  description = "Allow inbound traffic on port 22 and 80"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "metabase" {
  ami                  = "ami-0a70b9d193ae8a799" # Amazon Linux 2023 AMI
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  key_name             = "keys_mac"
  security_groups      = [aws_security_group.metabase_sg.name]

  user_data = file("${var.project_root}/dashboard/metabase/user_data.sh")

}
