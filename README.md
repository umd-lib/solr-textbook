# Textbook Availability Solr Core

## Introduction

**Note:** Previous versions of this repository were used as a Solr configuration
directory on solr.lib.umd.edu. This repository has now been changed to support
creating a Docker image containing the data.

When making updates to the data or configuration, a new Docker image should
be created.

## Generating the data.csv file

The "data.csv" file will be used to populate the Solr database. The "data.csv"
file is generated from the "Top Textbooks" spreadsheet.

The following steps for generating the "data.csv" from the Excel spreadsheet
were taken from [SolrDB Project: Textbook Availability](https://confluence.umd.edu/display/LIB/SolrDB+Project%3A+Textbook+Availability):

1) Examine the delivered Top Textbooks Excel spreadsheet and look for data
   errors. For example, in the demo sheet, data for "Year" and "Edition" was
   sometimes swapped. If any errors are minor, feel free to adjust and continue.
   Otherwise, we should reach out and request repaired data.

   * **Note:** We only care about the "DSS Sheet" spreadsheet tab. If we receive
   a spreadsheet without such a tab or fields that do not match the following
   (below), we may need to request clarification or an update.

   * Expected Columns
     * Course
     * Title
     * Edition
     * Year
     * Author
     * ISBN
     * Alternate ISBNs
     * Call number
     * Barcode
     * Current Status
     * New/Returning/Past Semester
     * UMCP copy?
     * Notes
     * Comment

2) Assuming all data is correct or fixed, export the spreadsheet to CSV and
  place somewhere easily accessible from the command line. For the export, I
  recommend using Excel's "Comma Separated Values (.csv)" format (in the
  "Specialty Formats" section) over the MS-DOS option. Open the file
  afterwards to ensure there is no odd formatting, such as the lines running
  together.

3) Open the CSV in a text editor and replace header row with a row matching the
  Solr schema fields. By this, you can simply delete the first row and replace
  it with the following (assuming no change in fields):

  ```
  course,program,title,edition,year,author,isbn,alternate_isbns,call_number,bar_code,current_status,new_returning_past_semester,umcp_copy,test_notes,comment
  ```

  Also do the following:

  a) Delete any empty record lines at the bottom of the file, i.e. lines that looked like:

  ```
  	,,,,,,,,,,,,,,
  ```

  b) Delete the last comma at the end of every line. In vi, this can be done by running

  ```
  %s/,$//g
  ```

  c) Search for "href" (used in hyperlinks for on-line resources), and verify
     that the URLs are fully-qualified, i.e., "https://rebrand.ly/a3acb", not
     "rebrand.ly/a3acb"

4) Copy the CSV file into this repository as "data.csv".

## Validating the data.csv file

The validation occurs automatically as part of the Docker image build, but if you want to run it manually, execute:

```bash
docker run -it --rm -v `pwd`/data.csv:/tmp/data.csv -v `pwd`/data.csvs:/tmp/data.csvs docker.lib.umd.edu/csv-validator:1.1.5-umd-0 validate /tmp/data.csv /tmp/data.csvs
```

See [CVS Schema Language](http://digital-preservation.github.io/csv-schema/csv-schema-1.1.html) for more information about validation rules you can add to [data.csvs](data.csvs).

## Building the Docker Image for Testing

When building the Docker image, the "data.csv" file will be used to populate
the Solr database.

To build the Docker image named "solr-textbook":

```
> docker build -t solr-textbook .
```

To run the freshly built Docker container on port 8983:

```
> docker run -it --rm -p 8983:8983 solr-textbook
```

Solr will then be available at [http://localhost:8983/](http://localhost:8983/).

## Building the Docker Image for Deployment

When building the Docker image for deployment, do the following:

```
> docker build --no-cache -t docker.lib.umd.edu/solr-textbook:<VERSION> -f Dockerfile .
```

where \<VERSION> is the Docker image version to use (typically the same as the
tagged version of this repository). For example, to create the "3.1.0" version:

```
> docker build --no-cache -t docker.lib.umd.edu/solr-textbook:3.1.0 -f Dockerfile .
```

**Note:** The "--no-cache" option is used to force Docker to download the latest
version of any images, instead of relying on whatever might be in the cache on a
particular workstation.

## License

See the [LICENSE](LICENSE.txt) file for license rights and limitations.
