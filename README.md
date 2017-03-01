# odk

A package for convenient analysis and presentation of data from the Open Data Kit (ODK) survey software. This is inteded to serve as an R alternative to the Stata program for basic ODK question types [odkmeta](https://github.com/PovertyAction/odkmeta).

## Development

Short-term ambitions:

- Reading the .XML files from ODK Briefcase into an R data frame with correct classes, option of including value labels, and removal of extraneous fields.
- Producing easy-to-read variables lists from .xlsx files used with XLSForm to produce XForms.
- Functionality will apply to the following question types: decimal, start, end, integer, text, select_one, select_multiple, calculate

Long-term ambitions:

- Create codebooks from either XML or .CSV files from ODK Aggregate or ODK Briefcase and ODK .xlsx file (or XForm).
- Add additional question types.


