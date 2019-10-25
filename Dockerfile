FROM solr:8.1.1
# Switch to root user
USER root
# Install xmlstarlet
RUN apt-get update -y && \
    apt-get install -y xmlstarlet
# Set the SOLR_HOME directory env variable
ENV SOLR_HOME=/apps/solr/data
# Create the SOLR_HOME directory and set ownership
RUN mkdir -p /apps/solr/ && \
    cp -r /var/solr/data /apps/solr/data && \
    chown -R solr:0 "$SOLR_HOME"

# Switch back to solr user
USER solr
# Create a the textbook core
RUN /opt/solr/bin/solr start && \
    /opt/solr/bin/solr create_core -c textbook && \
    /opt/solr/bin/solr stop
# # Replace the schema file
COPY conf /apps/solr/data/textbook/conf/
# Add the data to be loaded
ADD data.csv /tmp/data.csv
# Load the data to textbook core
RUN /opt/solr/bin/solr start && sleep 3 && \
    curl 'http://localhost:8983/solr/textbook/update?commit=true' -H 'Content-Type: text/xml' --data-binary '<delete><query>*:*</query></delete>' && \
    curl 'http://localhost:8983/solr/textbook/update?commit=true&header=true&fieldnames=course,program,title,edition,year,author,isbn,alternate_isbns,call_number,bar_code,current_status,new_returning_past_semester,umcp_copy,test_notes,comment&f.isbn.split=true&f.call_number.split=true&f.bar_code.split=true' \
        --data-binary @/tmp/data.csv -H 'Content-type:application/csv'&& \
    /opt/solr/bin/solr stop