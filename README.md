terraform-aws-basic-structure
=========

## これは何？

- AWS上で基本的なクラウド構成を実現する、tfファイルを集めたTerraformです。
- VPC＋EC2（オプションでオートスケール）＋ALB＋RDS＋CloudFrontの構成を作成します。

## 使い方
### 1.リポジトリをclone

```
git clone https://github.com/cocoacoco1021/terraform-aws-basic-structure.git
cd terraform-aws-basic-structure
```

### 2.main.tfに実行対象のAWSアカウントの情報を記載
```
vi main.tf
```
```
# ---------------------------------------------
# Provider
# ---------------------------------------------
provider "aws" {
  profile = "IAMアカウント名を追加"
  region  = "リージョン名を追加"
}
```

### 3.terraform.tfvarsに、情報を追加
```
terraform init
vi terraform.tfvars
```
```
project     = "プロジェクト名を追加"
environment = "環境名を追加"
```

### 4.Terraformを実行
```
terraform plan
terraform apply
```
