# Add auto-generated synonyms
FROM python:3.8 as synonyms

# Add the files
COPY data.csv /tmp/data.csv
COPY conf/synonyms.txt /tmp/synonyms.txt
COPY scripts/synonyms.py /tmp/synonyms.py

# Generate the synonyms
RUN python /tmp/synonyms.py --infile=/tmp/data.csv --outfile=/tmp/synonyms.txt

# Validate data.csv using csv-validator 1.1.5
# https://digital-preservation.github.io/csv-validator/
FROM docker.lib.umd.edu/csv-validator:1.1.5-umd-0 as validator

#COPY --from=cleaner /tmp/clean.csv /tmp/clean.csv
COPY data.csv /tmp/data.csv
COPY data.csvs /tmp/data.csvs

RUN validate /tmp/data.csv /tmp/data.csvs

# Load data.csv into the Solr core
FROM solr:8.11.0@sha256:f9f6eed52e186f8e8ca0d4b7eae1acdbb94ad382c4d84c8220d78e3020d746c6 as builder

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

# Create the textbook core
RUN /opt/solr/bin/solr start && \
    /opt/solr/bin/solr create_core -c textbook && \
    /opt/solr/bin/solr stop

# Replace the schema file
COPY conf /apps/solr/data/textbook/conf/
COPY --from=synonyms /tmp/synonyms.txt /apps/solr/data/textbook/conf/synonyms.txt

# Add the data to be loaded
COPY --from=validator /tmp/data.csv /tmp/data.csv

# Load the data to textbook core
RUN /opt/solr/bin/solr start && sleep 3 && \
    curl 'http://localhost:8983/solr/textbook/update?commit=true' -H 'Content-Type: text/xml' --data-binary '<delete><query>*:*</query></delete>' && \
    curl 'http://localhost:8983/solr/textbook/update?commit=true&header=true&fieldnames=uniqueid,course,title,edition,year,author,isbn,alternate_isbns,mms_id,call_number,bar_code,current_status,new_returning_past_semester,umcp_copy,test_notes,comment,branch_location&f.isbn.split=true&f.call_number.split=true&f.bar_code.split=true' \
        --data-binary @/tmp/data.csv -H 'Content-type:application/csv'&& \
    /opt/solr/bin/solr stop

# Create the Solr runtime container
FROM solr:8.11.0-slim@sha256:530547ad87f3fb02ed9fbbdbf40c0bfbfd8a0b472d8fea5920a87ec65aaacaef

ENV SOLR_HOME=/apps/solr/data

USER root
RUN mkdir -p /apps/solr/ && \
    cp -r /var/solr/data /apps/solr/data && \
    chown -R solr:0 "$SOLR_HOME"

USER solr
COPY --from=builder /apps/solr/ /apps/solr/
