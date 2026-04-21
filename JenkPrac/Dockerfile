# -------- BUILD STAGE --------
FROM eclipse-temurin:21-jdk-alpine AS build

WORKDIR /app

# Copy full project
COPY . .

# Ensure wrapper is executable
RUN chmod +x mvnw

# Build project
RUN ./mvnw clean package -DskipTests -B

# -------- RUNTIME STAGE --------
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copy built jar
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]