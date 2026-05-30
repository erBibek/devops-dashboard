name: DevOps Dashboard CI/CD Pipeline

on:
  push:
    branches: [ "main" ]

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build and Push Custom Image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/devops-dashboard:v2.1

  deploy-to-aws:
    runs-on: ubuntu-latest
    needs: build-and-push
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Copy Compose Infrastructure Files to AWS
        uses: appleboy/scp-action@v0.1.7
        with:
          host: ${{ secrets.AWS_HOST }}
          username: ${{ secrets.AWS_USERNAME }}
          key: ${{ secrets.AWS_PRIVATE_KEY }}
          source: "docker-compose.yml,nginx.conf"
          target: "~/app"

      - name: Execute Remote Deployment Commands via SSH
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.AWS_HOST }}
          username: ${{ secrets.AWS_USERNAME }}
          key: ${{ secrets.AWS_PRIVATE_KEY }}
          script: |
            cd ~/app
            docker compose pull
            docker compose down
            docker compose up -d