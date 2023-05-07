aws ecr create-repository \
    --repository-name splitfest \
    --region us-east-2



# 332795564348.dkr.ecr.us-east-2.amazonaws.com/splitfest
aws ecr get-login-password \
  --region us-east-2 \
  --profile my-dev-profile | docker login \
  --username AWS \
  --password-stdin 332795564348.dkr.ecr.us-east-2.amazonaws.com

docker tag splitfest/api:main 332795564348.dkr.ecr.us-east-2.amazonaws.com/splitfest:latest
docker push 332795564348.dkr.ecr.us-east-2.amazonaws.com/splitfest:latest
