# Use an official JDK base image for building 
FROM maven:3.9.4-eclipse-temurin-17 AS build

# Set workdir inside the container 

WORKDIR /app 

# Copy the project files (update if using multi-module)

COPY pom.xml .
COPY src ./src

# Package the application ( runs 'mvn package')

RUN mvn clean package -DskipTests

# ----------------

# Use a lighter JRE image for running the app
FROM eclipse-temurin:17-jre-alpine

# Set working directory
WORKDIR /app

# Copy Only the JAR from the build stage

COPY --from=build /app/target/*.jar app.jar 

#Expose port (update based on your app)

EXPOSE 8080

# Run the app 

ENTRYPOINT ["java","-jar","app.jar"]
