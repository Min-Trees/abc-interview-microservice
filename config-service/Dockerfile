FROM maven:3.9.8-eclipse-temurin-17 AS build
WORKDIR /build
COPY config-service/pom.xml .
RUN mvn -q -DskipTests dependency:go-offline
COPY config-service/src ./src
RUN mvn -q -DskipTests clean package

FROM eclipse-temurin:17-jre
WORKDIR /app
# copy jar đã build sẵn
COPY --from=build /build/target/config-service-*.jar app.jar
# Copy config-repo files into the image for native profile
COPY config-repo /config-repo
EXPOSE 8888
# tuỳ chọn: bật GC logging / heap size qua JAVA_OPTS khi run
ENV JAVA_OPTS="-XX:+UseG1GC -XX:MaxRAMPercentage=75"
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar /app/app.jar"]
