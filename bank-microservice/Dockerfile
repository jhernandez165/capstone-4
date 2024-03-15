FROM amazoncorretto:8-alpine3.16-jre
WORKDIR /root
COPY ./bank-microservice/target/bank-microservice-0.1.0.jar /root/bank-microservice-0.1.0.jar
ENTRYPOINT [ "java", "-jar", "bank-microservice-0.1.0.jar" ]