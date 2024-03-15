FROM amazoncorretto:8-alpine3.16-jre
WORKDIR /root
COPY ./account-microservice/target/account-microservice-0.1.0.jar /root/account-microservice-0.1.0.jar
ENTRYPOINT [ "java", "-jar", "account-microservice-0.1.0.jar" ]