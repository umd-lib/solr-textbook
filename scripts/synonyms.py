#!/usr/bin/env python3

import csv
from argparse import ArgumentParser, FileType

# Auto-generate synonyms

def process(args):
    """ Main loop for generating the synonyms."""

    # Gather the courses
    courses = {}
    reader = csv.DictReader(args.infile)
    for row in reader:

        # Extract course: program + number
        course = row['Course'].split()
        program = course[0]
        numbers = []
        for number in course[1:]:
            for remove_char in "(),":
                number = number.replace(remove_char,'')
            numbers.append(number)

        for number in numbers:
            courses[f'{program} {number}'] = f'{program}{number}'

    # Write the synomyms
    args.outfile.write('\n# Auto-generated synonyms\n')
    for course in sorted(courses.keys()):
        args.outfile.write(f'{courses[course]} => {course}\n')


if __name__ == '__main__':
    # Setup command line arguments
    parser = ArgumentParser()

    parser.add_argument("-i", "--infile", required=True,
                        type=FileType('r', encoding='UTF-8'),
                        help="CSV input file")

    parser.add_argument("-o", "--outfile", required=True,
                        type=FileType('a', encoding='UTF-8'),
                        help="synonyms.txt output file (append mode)")

    # Process command line arguments
    args = parser.parse_args()

    # Run the generation process
    process(args)
