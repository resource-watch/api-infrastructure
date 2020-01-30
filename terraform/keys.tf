# Public keys for logging onto EC2 instances
# Note: Adding new keys will destroy the Bastion host and recreate it with new user data

resource "aws_key_pair" "all" {
  for_each = {
    tmaschler_gfw       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCGI+i2fgsYXajjgKPPv3prXdEuFEQXrgtM6mVCK6nZeziuSW/3F0Y1JTCPp/SOw0p5I6ila0f1pzofeCeH+0MSwQ4q+tg66a6ZkgV16LWo0VYptBTIbDTUdp/O0KjxCviQLcZByvDd0AJAX81Cu7ChmZen0dq6U3lp9XWCQ/Lt3z2D8avikHvvtc9DZr6AmUD+fGEMBjKJI2KG7OizLJTLB2tvNJ5teEGNRVNI7ZiSgVg98Z0OeOODIM2QuVvU6xb6iCdGKdLRiNGf4Eq4Z71eiph+noaItziABWkiGha4EFbIWf4lKlH45mQn6BYhVtwtLnx6qsVA+PaErJuticnd tmaschler_gfw"
    tgarcia_vizzuality  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsQgoIZQAVAMFnESCsYotosbp3N2n8onp8Xmn0DZJmCnBzkfvn2SJdTQRKcyzjcHBqrseq+8Id0JYdb1aJJT2497b7NVOWvVLgqD5pYoxwLO4m3VjppUjpOfgGk3aBpzQTGwPHMqk4X4yvHNAuQcCTxo6gNIsyJZFxdzdc2P+oDLdTwekzsQvsPscFDXDYvtLTkCnSfeZAKsbb45XiAsH0HRnwzJYPvPr69V6c1R3igc2aDZ+eI2sZPvsCXWnvJYfL0QLJp+NwqJuRzHygcxsByg9p/wTPko2vEQLGvefBqjMFHbDYRyVh1omfwt3w/l5R6Abb1Mc2sNDqhBKFEe7/ tgarcia_vizzuality"
    hpacheco_vizzuality = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOXiXrNrp8HmNTYGb9/lZVXg8aQpfHJkCQyD17VGqti7cuQA4d6S1c4pqDqOXdg/NhDpmZN6f3rZiGaY7pX3FLmxj0mS8y1UJcbB3Lj9IP/wGB2uFtn67YDPtvcvsquDK3dHg0XdHmgmDaYMRXY4tXUitS++JfMCfqy3lrTzmbb2wxVmKYLW8vHtCNE0EmsK/dNZLLbCgFjQuJacfx1eJKYd6pNZ+LW1Xsrn0bIBDfC3rxdOec/xbJjwQuDLUJhVYeayyQ6raj4qG6fHiiYuyok99m/MpFuhy+coWz8IxlOJspDD10ufsSJy7hmLutW82/OsLor+et6SxqRDkGtCMUX37DW9Tx98lca8kFjCSppa/DMYgX1iIjkO7dCO90WaHml2lY5Xo6ks2r0+vyd6Rp0XU/ASryBrhfmpDTUEo5RLzYDLkU3HSGH4sWS7fcbWIwP6VNmH+9U4jIndW7vKZ7iwHJq4X0a7qsuIMN1OaVgzXoT+tBWEjMmgZ57N5ppbMz3LPBH1WOWZERmdwz7k0HXz0o9RAtHteDkdgqNTVNhHNOE1fXR0DR9VFnQK/3oz9ldUK6daP1KFgVH5/om4WLzMAb32923kzDm2jIDk4P+7M3+oyO4AQ+5NY9BwM3qP57EfkER7uIyRe4texdbOgfkykDVVVb4HsUwePTl/7Mhw== hpacheco_vizzuality"
  }
  key_name   = each.key
  public_key = each.value
}
