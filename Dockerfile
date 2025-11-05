
FROM maven:3.8.6-openjdk-11 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:11-jre
WORKDIR /app
COPY --from=build /app/target/service-discovery-*.jar service-discovery.jar
ENV SPRING_PROFILES_ACTIVE=dev
EXPOSE 8761
ENTRYPOINT ["java", "-Dspring.profiles.active=${SPRING_PROFILES_ACTIVE}", "-jar", "service-discovery.jar"]


