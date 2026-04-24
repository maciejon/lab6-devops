FROM maven:3.9.5-eclipse-temurin-17 AS bldr
WORKDIR /app
COPY . .

FROM eclipse-temurin:17-jre AS target
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
