# odk

A package for convenient data analysis and survey documentation in R for users of the Open Data Kit (ODK) survey ecosystem. Primarily an R-based alternative to the Stata program [odkmeta](https://github.com/PovertyAction/odkmeta).

## Project Background

Many ODK users often wish to produce a codebook allowing for easy examination of a survey's response option values, response option value labels, variable names, and skip logic. While Stata users may rely on [odkmeta](https://github.com/PovertyAction/odkmeta) to produce codebooks, R users often must manually produce codebooks. This can leads to transcription errors, spelling errors, and is often both tedious and time-consuming. Furthermore, while tools in the ODK ecosystem (such as [ODK Aggregate](https://opendatakit.org/use/aggregate/) or [ODK Briefcase](https://opendatakit.org/use/briefcase/)) require the survey to be in an [XForm](https://en.wikipedia.org/wiki/XForms), many users do not possess the skill or time to create their own XForms from scratch Instead, they typically create a specifically structured a .xlsx file containing the survey and use [XLSForm](http://xlsform.org/) to produce an XForm. This package automates the production of codebooks by enabling users of XLSForm to convert their .xslx files directly into codebooks in two file formats: a .docx file editable in Microsoft Word (or open source alternatives) and a .csv file editable in most text editors.

Additionally, data managers and analysts sometimes must work with the raw survey output in the .xml files stored on tablet rather than the .csv files ODK tools such as ODK Aggregate produce when exporting data. This package automates the conversion of these .xml files into .csv files more readily analyzed in conventional statistic software.

## Development

The package will ultimately comprise two different scripts:

- [**odk_to_codebook**](src/odk_to_codebook.R) enables conversion of .xslx files used to produce XForms via XLSForm
- **xml_to_csv** enables conversion of .xml files to .csv files

Currently there is an additional file that provides some small functions that are useful in the analysis of ODK files. These were defined for a specific project and may require some tweaking for your particular use-case.
