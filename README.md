Textbook Availability Solr Core
=================

Textbook Availability Solr core configuration repository.


Check out this repository to the `cores` directory of the solr installation.

```
git clone git@bitbucket.org:jgottwig-umd/textbook-core.git
```

This is a 6.x core utilizing a managed schema.

Reindexing Textbook Availabilty Data
=======================
1. Convert header fields to match schema fields:
  * course,program,title,edition,year,author,isbn,alternate_isbns,call_number,bar_code,current_status,new_returning_past_semester,umcp_copy,comment,test_notes
2. Run command:
  * curl "http://localhost:8983/solr/textbook/update/csv?commit=true&f.isbn.split=true&f.call_number.split=true&f.bar_code.split=true" --data-binary @textbook-spring-2017.csv -H 'Content-type:text/csv; charset=utf-8'
