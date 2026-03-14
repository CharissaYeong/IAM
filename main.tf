resource "aws_instance" "web_instance" {
  ami           = data.aws_ami.amazon_linux.id 
  instance_type = "t2.micro"
  subnet_id = data.aws_subnets.public.ids[0]
  
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2_key.key_name
  iam_instance_profile = aws_iam_instance_profile.profile_example.name

  tags = {
    Name = "${local.name_prefix}-ec2"
  }
}


resource "aws_dynamodb_table" "book_inventory" {
  name         = "${local.name_prefix}-bookinventory"
  billing_mode = "PAY_PER_REQUEST"   
  hash_key     = "ISBN"              # Partition key
  range_key    = "Genre"             # Sort key

  attribute {
    name = "ISBN"
    type = "S"                        # String type
  }

  attribute {
    name = "Genre"
    type = "S"                        # String type
  }

  tags = {
    Name        = "BookInventory"
    Environment = "Dev"
  }
}


resource "aws_dynamodb_table_item" "books" {
  for_each  = local.books
  table_name = aws_dynamodb_table.book_inventory.name

  hash_key  = "ISBN"
  range_key = "Genre"

  item = jsonencode({
    ISBN   = { S = each.value.ISBN }
    Genre  = { S = each.value.Genre }
    Title  = { S = each.value.Title }
    Author = { S = each.value.Author }
    Stock  = { N = tostring(each.value.Stock) }
  })
}


resource "aws_db_subnet_group" "rds_subnets" {
  name       = "${local.name_prefix}-subnet-group"
  subnet_ids = data.aws_subnets.private.ids
  

  tags = {
    Name = "${local.name_prefix}-rds-subnet-group"
  }
}


resource "aws_db_instance" "example_rds" {
  identifier           = "${local.name_prefix}-rds"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = random_password.rds_password.result
  skip_final_snapshot  = true
  publicly_accessible  = false

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name

  tags = {
    Name = "${local.name_prefix}-rds"
  }
}

output "rds_endpoint" {
  value = aws_db_instance.example_rds.endpoint
}
