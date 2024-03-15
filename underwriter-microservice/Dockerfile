FROM amazoncorretto:8-alpine3.16-jre
WORKDIR /root
COPY ./underwriter-microservice/target/underwriter-microservice-0.1.0.jar /root/underwriter-microservice-0.1.0.jar
ENTRYPOINT [ "java", "-jar", "underwriter-microservice-0.1.0.jar" ]