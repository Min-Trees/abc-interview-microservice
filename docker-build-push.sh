push

$DOCKER_USER="mintreestdmu"
$VERSION="1.0.0"
$SERVICES=@("config-service","discovery-service","gateway-service","user-service","auth-service","career-service")

foreach ($SERVICE in $SERVICES) {
  echo "🚀 Building $SERVICE ..."
  docker build -t "$DOCKER_USER/${SERVICE}:$VERSION" "./$SERVICE"
  docker push "$DOCKER_USER/${SERVICE}:$VERSION"
}


pull
$DOCKER_USER="mintreestdmu"
$VERSION="1.0.0"
$SERVICES=@("config-service","discovery-service","gateway-service","user-service","auth-service","career-service")

foreach ($SERVICE in $SERVICES) {
  echo "📥 Pulling $SERVICE ..."
  docker pull "$DOCKER_USER/${SERVICE}:$VERSION"
}
