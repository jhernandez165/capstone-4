FROM amazoncorretto:8-alpine3.16-jre
WORKDIR /root
COPY ./card-microservice/target/card-microservice-0.1.0.jar /root/card-microservice-0.1.0.jar
ENTRYPOINT [ "java", "-jar", "card-microservice-0.1.0.jar" ]