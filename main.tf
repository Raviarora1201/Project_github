provider "aws" {

}

resource "aws_vpc" "my_vpc"{
    cidr_block = "10.10.0.0/16"
    instance_tenancy = "default"
    enable_dns_hostnames = "true"
    tags{
        name = "myfirst_vpc"
}
}
resource "aws_internet_gateway" "my_internet_gateway"{
    vpc_id = "${aws_vpc.my_vpc.id}"
    tags{
        name = "myfirst_internet_gateway"
}
}

resource "aws_route_table" "my_public_route_table"{
    vpc_id = "${aws_vpc.my_vpc.id}"
    route{
    	   cidr_block = "0.0.0.0./0"
           gateway_id = "${aws_internet_gateway.my_internet_gateway.id}"
         }
   tags
        {
          name = "My Public Route table"
        }
}

resource "aws_default_route_table" "my_private_route_table"{
   default_route_table_id = "${aws_vpc.my_vpc.id}"
   tags{
            name = "My Private route table"
       }
}

#Subnets

resource "aws_subnet" "my_public_subnet1"{
   vpc_id = "${aws_vpc.my_vpc.id}"
   cidr_block = "10.10.1.0/24"
   map_public_ip_on_launch = true
   availability_zone = "us-east-2a"
   tags{
          name = "myfirst Public Subnet1"
       }
}

resource "aws_subnet" "my_public_subnet3"{
   vpc_id = "${aws_vpc.my_vpc.id}"
   cidr_block = "10.10.3.0/24"
   map_public_ip_on_launch = true
   availability_zone = "us-east-2b"
   tags{
         name = "myfirst Public Subnet3"
       }
}

resource "aws_subnet" "my_private_subnet2"{
   vpc_id = "${aws_vpc.my_vpc.id}"
   cidr_block = "10.10.2.0/24"
   map_public_ip_on_launch = false
  availability_zone = "us-east-2a"
  tags{
       name = "my Private Subnet2"
      }
}

resource "aws_subnet" "my_private_subnet4"{
   vpc_id = "${aws_vpc.my_vpc.id}"
   cidr_block = "10.10.4.0/24"
   map_public_ip_on_launch = false
   availability_zone = "us-east-2b"
   tags{
       name = "my Private Subnet4"
      }
}

#subnet associations

resource "aws_route_table_association" "my_public_subnet1_assoc"{
   subnet_id = "${aws_subnet.my_public_subnet1.id}"
   route_table_id = "${aws_route_table.my_public_route_table.id}"
}

resource "aws_route_table_association" "my_public_subnet3_assoc"{
   subnet_id = "${aws_subnet.my_public_subnet3.id}"
   route_table_id = "${aws_route_table.my_public_route_table.id}"
}

resource "aws_route_table_association" "my_private_subnet2_assoc"{
   subnet_id = "${aws_subnet.my_private_subnet2.id}"
   route_table_id = "${aws_default_route_table.my_private_route_table.id}"
}

resource "aws_route_table_association" "my_private_subnet4_assoc"{
   subnet_id = "{aws_subnet.my_private_subnet4.id}"
   route_table_id = "${aws_default_route_table.my_private_route_table.id}"
}

#Security Group

resource "aws_security_group" "my_public_security_group"{
   name = "public security group"
   description = " Use for linux intance access through SSh"
   vpc_id = "${aws_vpc.my_vpc.id}"

   ingress{
          from_port = 22
          to_port = 22
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          }
    egress{
          from_port = 0
          to_port = 0
          protocol = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          }
          tags{
              name = "my public route table"
}
}

#key pair

# resource "aws_key_pair" "my_ec2_keypair"{
#
#     key_name = "my_ec2_keypair"
#     public_key = "${file("/root/my_ec2_keypair.pub")}"
# }

#instance creation

resource "aws_instance" "my-instance1"{
       instance_type = "t2.micro"
       ami = "ami-922914f7"
       key_name = "myKey2"
       vpc_security_group_ids = ["${aws_security_group.my_public_security_group.id}"]
       subnet_id = "${aws_subnet.my_public_subnet1.id}"
       tags{
        name = "my_instance01"
        }
       ebs_block_device{
        device_name = "/dev/sdb"
        volume_size = 500
        delete_on_termination = true
        }

       provisioner "file"{
        source = "/root/script.sh"
        destination = "/tmp/script.sh"
       }
       provisioner "remote-exec"{
          inline = [
          "chmod +x /tm/script.sh",
          "/tmp/script.sh args",
         ]
       }
}
