FROM openjdk:11-jre
LABEL authors="rodo"
COPY target/Hello-rodo-1.0-SNAPSHOT-jar-with-dependencies.jar /app/MiApp.jar
WORKDIR /app
CMD ["java", "-jar", "MiApp.jar"]
