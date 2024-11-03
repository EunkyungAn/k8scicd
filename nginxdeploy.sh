# nginx 디렉터리 생성
mkdir nginx

# nginx deployment 작성
cat > nginx/deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
EOF

# nginx service 작성
cat > nginx/service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    protocol: TCP
  selector:
    app: nginx
EOF

# git commit & push
git add nginx
git commit -m "Initialize nginx manifest"
git push
