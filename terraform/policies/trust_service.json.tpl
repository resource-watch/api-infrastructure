{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "${service}.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}