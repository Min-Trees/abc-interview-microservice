# ====== BUILD STAGE ======
FROM maven:3.9.8-eclipse-temurin-17 AS build
WORKDIR /build

COPY pom.xml .
RUN mvn -q -DskipTests dependency:go-offline

COPY src ./src
RUN mvn -q -DskipTests clean package

# ====== RUNTIME STAGE ======
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy file jar của career-service sau khi build
COPY --from=build /build/target/career-service-*.jar app.jar

# Mặc định career-service chạy cổng 8084 (bạn chỉnh nếu dự án dùng cổng khác)
EXPOSE 8084

ENV JAVA_OPTS="-XX:+UseG1GC -XX:MaxRAMPercentage=75"
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar /app/app.jar"]
