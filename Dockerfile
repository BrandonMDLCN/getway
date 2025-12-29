#
# Build del proyecto (Multi-Stage)
# --------------------------------
#
# Usamos una imagen de Maven para hacer build de proyecto con Java
# Llamaremos a este sub-entorno "build"
# Copiamos todo el contenido del repositorio
# Ejecutamos el comando mvn clean package (Generara un archivo JAR para el despliegue)
FROM maven:3.9.6-eclipse-temurin-21-alpine AS build
WORKDIR /app

# Copiamos solo el pom y descargamos dependencias (optimiza caché)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copiamos el código fuente y compilamos
COPY src ./src
RUN mvn clean package -DskipTests

# Usamos una imagen de Openjdk
# Exponemos el puerto que nuestro componente va a usar para escuchar peticiones
# Copiamos desde "build" el JAR generado (la ruta de generacion es la misma que veriamos en local) y lo movemos y renombramos en destino como 
# Marcamos el punto de arranque de la imagen con el comando "java -jar app.jar" que ejecutará nuestro componente.
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8762
ENTRYPOINT ["java", "-jar", "app.jar"]