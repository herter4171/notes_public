# notes
This repository is intended to house the means for creating a single-viewer Wordpress site for personal notes.  To accomplish this, a single AWS instance that's free-tier eligible is configured and set to be locked down to a single IP to aid exclusivity.  Of course others on that IP can view "public" posts, but they'd have to guess the IP first.

## Tech Stack
Tools in use include the following.
* Packer builds an AMI with Docker installed
  * Using an Ansible playbook
  * Assumes the following about **local** credentials
    * GitHub private key at `~/.ssh/id_rsa`
    * AWS credentials at `~/.aws`
* Terraform to deploy
  * Instance of type `t2.micro` for hosting
  * EIP for the above instance
  * Security group locked down to the desired IP
  * S3 bucket for backing up site content
* Docker and Docker compose to run the site

## Deployment
The first thing that's needed is an AMI with Docker installed.

### Packer
To run Packer, you first need to download the zip file from [here](https://www.packer.io/downloads), then put the binary in the directory `packer`.  If paths for your AWS credentials or GitHub private key differ from what's in the bottom of [packer/playbook.yml](packer/playbook.yml), you will want to modify accordingly.  From there, simply run the following in the `packer` directory.
```
./packer build ami_gen.json
```

This provisions a temporary instance for AMI generation that runs the Ansible Playbook, creates the AMI, and terminates.

### Terraform
Similar to Packer, you first want to download the zip file from [here](https://www.terraform.io/downloads.html), then put the binary in the directory `terraform`.  After that, there are a few things that may need updating.

1. For the instance given in [terraform/main.tf](terraform/main.tf), update `ami` with your new AMI ID
1. If your preferred AWS region isn't `us-west-1` change the second line in the same file as above
1. Change the default for variable `home_ip` in [terraform/variables.tf](terraform/variables.tf) to your public IP

Once everyting is up to date, you can run the following in the `terraform` directory and follow the prompts.
```
./terraform apply
```
This will provision the backbone of what's needed for an operable site.

### Docker
To start, shell into your new instance, and mount the S3 bucket.
```
s3fs wp-backup-2676 /s3
```
You can verify the mount via
```
grep 's3fs\s/s3' /proc/mounts
```

Next, clone this repository to your home folder `/home/ec2-user`.
```
git clone git@github.com:herter4171/notes_public.git
```
#### Backup Cron Job
Open a new `cron` file as root.
```
sudo vim /etc/cron.d/backup
```
With that file open, paste the following (or whatever is desired for timing), then save it.
```
0 7 * * 0 ec2-user /bin/bash /home/ec2-user/notes_public/backup_s3.sh
```
The above runs once every Sunday at 7 am UTC.

#### Env File Setting
From inspection of [docker-compose.yml](docker-compose.yml), it's clear we need to define `WP_USER` and `WP_PASS`.  To do so, make a new file called `.env` in the top repo directory **on the remote**, and populate it similar to the following.
```
WP_USER="myself"
WP_PASS="asdf@#fasdf"
```

#### Launching the Site
With everything out of the way, you should be able to launch by running the following command at the top repo directory on the remote.
```
docker-compose up -d
```

## Usage
Once the site is up, you should be able to navigate to it in a browser using the IP followed by `/wp-admin`, and credentials will match what's in the remote `.env` file.  From there, you should be all set to begin writing posts only visible to you.