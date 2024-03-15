FROM amazoncorretto:8-alpine3.16-jre
WORKDIR /root
COPY ./transaction-microservice/target/transaction-microservice-0.1.0.jar /root/transaction-microservice-0.1.0.jar
ENTRYPOINT [ "java", "-jar", "transaction-microservice-0.1.0.jar" ]