
FROM tomcat:9.0-jdk21-temurin

# Remove Tomcat's default applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Deploy Petclinic as the ROOT application
COPY target/petclinic.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
