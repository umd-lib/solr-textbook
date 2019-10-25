Textbook Availability Solr Core
=================

Textbook Availability Solr core configuration repository.


Check out this repository to the `cores` directory of the solr installation.

```
git clone git@bitbucket.org:umd-lib/textbook-core.git textbook
```

This is a 6.x core utilizing a managed schema.


Build and Run Docker Container
=================

To Build an image

```
docker build -t textbook .
```

To run the freshly built Docker container on port 8983

```
docker run -it --rm -p 8983:8983 textbook
```


Reindexing Textbook Availabilty Data
=======================
See **Initializing and Reindexing Textbook Availabilty Data** section in [SolrDB Project: Textbook Availability](https://confluence.umd.edu/display/LIB/SolrDB+Project%3A+Textbook+Availability)
