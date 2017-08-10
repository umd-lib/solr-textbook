Textbook Availability Solr Core
=================

Textbook Availability Solr core configuration repository.


Check out this repository to the `cores` directory of the solr installation.

```
git clone git@bitbucket.org:umd-lib/textbook-core.git textbook
```

This is a 6.x core utilizing a managed schema.

Reindexing Textbook Availabilty Data
=======================
1. Examine the delivered Top Textbooks Excel spreadsheet and look for data errors. For example, in the demo sheet, data for "Year" and "Edition" was sometimes swapped. If any errors are minor, feel free to adjust and continue. Otherwise, we should reach out and request repaired data. Note that we only care about the "Full List" spreadsheet tab. If we receive a spreadsheet without such a tab or fields that do not match the following (below), we may need to request clarification or an update.
	* Note: The Comment and Test notes fields were likely only included for the demo data. It should not be a problem if these fields are not included in the updated spreadsheet.
	* Expected Fields:
		* Course
		* Program
		* Title
		* Edition
		* Year
		* Author
		* ISBN
		* Alternate ISBNs
		* Call Number
		* Barcode
		* Current Status
		* New/Returning/Past Semester
		* UMCP copy?
		* Comment
		* Test notes
1. Assuming all data is correct or fixed, export the spreadsheet to CSV and place somewhere easily accessible from the command line. For the export, I recommend using Excel's "Windows Comma Separated (.csv)" format over the MS-DOS option. Open the file afterwards to ensure there is no odd formatting, such as the lines running together.
1. Open the CSV in a text editor and replace header row with a row matching the Solr schema fields. By this, you can simply delete the first row and replace it with the following (assuming no change in fields):

	course,program,title,edition,year,author,isbn,alternate_isbns,call_number,bar_code,current_status,new_returning_past_semester,umcp_copy,comment,test_notes

1. Clear current "textbook" index. For this, you could adjust the URL and apply the following string:

	curl https://path/to/solr6/textbook/update?commit=true -H "Content-Type: text/xml" --data-binary '<delete><query>\*:\*</query></delete>'

1. Load the updated data by adjusting the URL and applying the following command:

	curl "https://path/to/solr6/textbook/update/csv?commit=true&f.isbn.split=true&f.call_number.split=true&f.bar_code.split=true" --data-binary @textbook-spring-2017.csv -H 'Content-type:text/csv; charset=utf-8'

1. Log into Solr and confirm that the record count now matches the spreadsheet row count (minus one for header row).
