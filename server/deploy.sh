#!/bin/bash
# Builds every service and deploys the Django app to the Skills Network lab
# Kubernetes cluster.
#
# Usage: ./deploy.sh <backend_url> <sentiment_analyzer_url>
#   backend_url             public URL of the Express service (port 3030)
#   sentiment_analyzer_url  public URL of the sentiment analyzer (port 5050)
set -e

if [ $# -ne 2 ]; then
  echo "Usage: $0 <backend_url> <sentiment_analyzer_url>"
  exit 1
fi

BACKEND_URL="${1%/}"
SENTIMENT_URL="${2%/}/"
cd "$(dirname "$0")"

# The Django container reads the service URLs from this file
printf 'backend_url=%s\nsentiment_analyzer_url=%s\n' \
  "$BACKEND_URL" "$SENTIMENT_URL" > djangoapp/.env

echo "== MongoDB and the dealers and reviews API"
(cd database && docker build . -t nodeapp \
  && (docker-compose up -d || docker compose up -d))

echo "== Sentiment analyzer"
(cd djangoapp/microservices && docker build . -t senti_analyzer)
docker rm -f senti_analyzer 2>/dev/null || true
docker run -d --name senti_analyzer -p 5050:5000 senti_analyzer

echo "== React front end"
(cd frontend && npm install && npm run build)

echo "== Django image"
MY_NAMESPACE=$(ibmcloud cr namespaces | grep sn-labs- | tr -d ' ')
echo "Namespace: $MY_NAMESPACE"
docker build -t "us.icr.io/$MY_NAMESPACE/dealership" .
docker push "us.icr.io/$MY_NAMESPACE/dealership"

echo "== Kubernetes deployment"
sed "s#<your-namespace>#$MY_NAMESPACE#" deployment.yaml | kubectl apply -f -
kubectl rollout status deployment/dealership --timeout=300s

echo "Done. Now run: kubectl port-forward deployment.apps/dealership 8000:8000"
