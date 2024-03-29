# Public keys for logging onto EC2 instances
# Note: Adding new keys will destroy the Bastion host and recreate it with new user data

resource "aws_key_pair" "all" {
  for_each = {
    snegusse_wri       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHwKzgoKejAQHhT9Uw8WcXoq8e8YkJ9N4L/fCRkNqarvZfn6uo+u4iq5W0UEVOnjBgANCrCtkmV/z6xlZ6P+ncrqJbimYSfNxE5KAkSvfsCKOfxcKI3y3uoM+SSSC61A4IK4/RgckYcR71KZeQ21/2WyPTnqyJSweseDvyp26fAoGcFjErUJdfU/bYC5PkQ6rg3F2yfVufCvRIRVUf5ZM4tFDgGAosut3sB7xjiplz2vEZAmA9l6f3IcKFEFHAHuje+FFy9lLtG/i3PZD3WICrcAboprw42tnPHXqgP++UTYZHknw5DFfZPtcXV+OON97ObdmgRuWLCDbHFpuuvpOjZ8EiBAHL7gNTcrmx38rsHtWD/yIFBuXFkpHKfGPHrXNBYEaQwKnCBhs5GKuFNNkCPx1M1gOlIAuTDowOcvEjULIeCNdrOVVjVVxkcls00/G6bTmmZIZIOz3v3SqtJBp/0id9P8xPVwMeqkVhH7RvGoSPoYgg2FUkvr/vM5owlb0= solomon.negusse@wri.org"
    tgarcia_vizzuality = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsQgoIZQAVAMFnESCsYotosbp3N2n8onp8Xmn0DZJmCnBzkfvn2SJdTQRKcyzjcHBqrseq+8Id0JYdb1aJJT2497b7NVOWvVLgqD5pYoxwLO4m3VjppUjpOfgGk3aBpzQTGwPHMqk4X4yvHNAuQcCTxo6gNIsyJZFxdzdc2P+oDLdTwekzsQvsPscFDXDYvtLTkCnSfeZAKsbb45XiAsH0HRnwzJYPvPr69V6c1R3igc2aDZ+eI2sZPvsCXWnvJYfL0QLJp+NwqJuRzHygcxsByg9p/wTPko2vEQLGvefBqjMFHbDYRyVh1omfwt3w/l5R6Abb1Mc2sNDqhBKFEe7/ tgarcia_vizzuality"
  }
  key_name   = each.key
  public_key = each.value
}
