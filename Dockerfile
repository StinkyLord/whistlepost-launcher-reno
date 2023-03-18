ARG ARCH=""
ARG JAVA_VERSION="11"
FROM ${ARCH}eclipse-temurin:${JAVA_VERSION} as jre-build

# Create a custom Java runtime
RUN $JAVA_HOME/bin/jlink \
         --add-modules java.base,java.logging,java.desktop,jdk.crypto.cryptoki,java.naming,java.management,java.rmi,java.scripting,java.transaction.xa,java.sql,java.compiler,java.security.jgss \
         --strip-debug \
         --no-man-pages \
         --no-header-files \
         --compress=2 \
         --output /javaruntime

# Define your base image
FROM ${ARCH}debian:buster-slim
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH "${JAVA_HOME}/bin:${PATH}"
COPY --from=jre-build /javaruntime $JAVA_HOME
RUN apt update && apt install -y curl

WORKDIR /opt/whistlepost

# Continue with your application deployment
COPY target/dependency/org.apache.sling.feature.launcher.jar /opt/whistlepost/
COPY target/slingfeature-tmp/feature-whistlepost.json /opt/whistlepost/
COPY target/artifacts /opt/whistlepost/deps
RUN #mkdir deps && unzip whistlepost-launcher-1.0.0-SNAPSHOT-package.zip -d deps
ENTRYPOINT ["java", "-jar", "./org.apache.sling.feature.launcher.jar", "-u", "file:///opt/whistlepost/deps, https://repo.maven.apache.org/maven2, https://repository.apache.org/content/groups/snapshots", "-f", "./feature-whistlepost.json"]

HEALTHCHECK CMD curl --fail http://localhost:8080/system/health/installer.txt?httpStatus=CRITICAL:503 || exit 1