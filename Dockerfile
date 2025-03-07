
# Use base cloud run image, currently based on Ubuntu 18 - try to get buildpack and run image to be in concordance for Ubuntu 22
FROM gcr.io/buildpacks/gcp/run
USER root
# Set environment variables to accept EULA and avoid interactive prompts
ENV ACCEPT_EULA=Y
#all that's needed any nonzero value - for troubleshooting segfault when trying to connect of over ODBC
ENV PYTHONBUFFERED=true

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    software-properties-common

## ODBC setup
# converted from https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server
# Download the package to configure the Microsoft repo

RUN curl -sSL -O https://packages.microsoft.com/config/ubuntu/$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2)/packages-microsoft-prod.deb && \
dpkg -i packages-microsoft-prod.deb
RUN cat /etc/apt/sources.list
RUN apt-get update && apt-get install -y --no-install-recommends -oDebug::RunScripts=1 msodbcsql18

#Debug ODBC setup
RUN odbcinst -j
RUN odbcinst -q -d
RUN dpkg -L msodbcsql18

    # Install unixODBC and dependencies
RUN apt-get install -y unixodbc-dev
RUN apt-cache policy unixodbc-dev

#make sure all users can access dirs
RUN chmod -R o+rx /opt/microsoft/msodbcsql18/
COPY ./odbcinst.ini /etc/odbcinst.ini
RUN chmod -R o+rx /etc/odbcinst.ini
RUN find . -name lib*odbc*.so*
RUN chmod -R o+rx /opt/microsoft/msodbcsql18/etc/odbcinst.ini
## END ODBC setup

RUN apt-get install -y python3-pip

# Clean up package lists
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && rm packages-microsoft-prod.deb

#USER 33:33
