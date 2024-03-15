FROM amazoncorretto:8-alpine3.16-jre
WORKDIR /root
COPY ./user-microservice/target/user-microservice-0.1.0.jar /root/user-microservice-0.1.0.jar
ENTRYPOINT [ "java", "-jar", "user-microservice-0.1.0.jar" ]