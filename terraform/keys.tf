# Public keys for logging onto EC2 instances
# Note: Adding new keys will destroy the Bastion host and recreate it with new user data

resource "aws_key_pair" "all" {
  for_each = {
    tmaschler_gfw      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCGI+i2fgsYXajjgKPPv3prXdEuFEQXrgtM6mVCK6nZeziuSW/3F0Y1JTCPp/SOw0p5I6ila0f1pzofeCeH+0MSwQ4q+tg66a6ZkgV16LWo0VYptBTIbDTUdp/O0KjxCviQLcZByvDd0AJAX81Cu7ChmZen0dq6U3lp9XWCQ/Lt3z2D8avikHvvtc9DZr6AmUD+fGEMBjKJI2KG7OizLJTLB2tvNJ5teEGNRVNI7ZiSgVg98Z0OeOODIM2QuVvU6xb6iCdGKdLRiNGf4Eq4Z71eiph+noaItziABWkiGha4EFbIWf4lKlH45mQn6BYhVtwtLnx6qsVA+PaErJuticnd tmaschler_gfw"
    tgarcia_vizzuality = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsQgoIZQAVAMFnESCsYotosbp3N2n8onp8Xmn0DZJmCnBzkfvn2SJdTQRKcyzjcHBqrseq+8Id0JYdb1aJJT2497b7NVOWvVLgqD5pYoxwLO4m3VjppUjpOfgGk3aBpzQTGwPHMqk4X4yvHNAuQcCTxo6gNIsyJZFxdzdc2P+oDLdTwekzsQvsPscFDXDYvtLTkCnSfeZAKsbb45XiAsH0HRnwzJYPvPr69V6c1R3igc2aDZ+eI2sZPvsCXWnvJYfL0QLJp+NwqJuRzHygcxsByg9p/wTPko2vEQLGvefBqjMFHbDYRyVh1omfwt3w/l5R6Abb1Mc2sNDqhBKFEe7/ tgarcia_vizzuality"
  }
  key_name   = each.key
  public_key = each.value
}
