
FROM maven:3.8.6-openjdk-11 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM openjdk:11-jre-slim
ARG PROJECT_VERSION=0.1.0
WORKDIR /app
COPY --from=build /app/target/service-discovery-v${PROJECT_VERSION}.jar service-discovery.jar
ENV SPRING_PROFILES_ACTIVE=dev
EXPOSE 8761
ENTRYPOINT ["java", "-Dspring.profiles.active=${SPRING_PROFILES_ACTIVE}", "-jar", "service-discovery.jar"]


