variable "subnet1"{
 default =  "subnet-56927032"
}
provider "aws"{
    region = "us-east-1"
}

#instance
resource "aws_instance" "web" {
    ami = "ami-14c5486b"
    instance_type = "t2.micro"
    subnet_id = "${var.subnet1}"
    tags {
        Name = "HelloWorld"
    }
}
