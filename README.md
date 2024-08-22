# Standardizing ICD-10 Code data from CMS.gov

## Synopsis

ICD-10 Codes are codes for diseases, signs and symptoms, abnormal findings, complaints, social circumstances, and external causes of injury or diseases.
These codes are important in the treatment of people by accurately diagnosing their diseases and conditions.

The codes are located here: https://www.cms.gov/medicare/coordination-benefits-recovery/overview/icd-code-lists

One list of ICD-10 Codes is available here in only XLSX format: https://www.cms.gov/files/document/valid-icd-10-list.xlsx

## Motivation

The ICD-10 codes are a mess and the `.xlsx` format isn't useful for anyone beyond those that live in an EXCEL compatible program.

The purpose of this repository are 2 fold:

- Creating processes to show how to convert this `.xlsx` file into other formats AND standardizing the data in such a way that it is more useful for developers and data scientists.
- Showcasing different methods to perform these translations given a real-world example of having "messy" data.

# Setting up

The quickest way to convert the data from `.xlsx` to `.csv` is to:

- Download the `.xlsx` file locally
- Import the file into Google Sheets
- Export from Google Sheets a `.csv` file

# Normalizing the data

The data will contain the following issues that will need to be processed:

- Certain records will have a comma value within double-quotes that will cause problems since each comma is a delimiter

```bash
ABC123, "Testing, one", "Testing, two",
```

- Certain records will have a "[]" character pair surrounding a specific word

```bash
B0821,Exanthema subitum [sixth disease] due to human herpesvirus 6,Exanthema subitum [sixth disease] due to human herpesvirus 6,
```

- Certain records will have a "[]" character pair AND a `'` character:

```bash
A751,Recrudescent typhus [Brill's disease],Recrudescent typhus [Brill's disease],
```

- Certain records will have a comma separated value within double-quotes that needs to be replaced AND have "[]" characters

```bash
DEFG456, "[EXCLUDE] Testing, three", "[EXCLUDE] Testing, four",
```

- Certain records will return early and be broken up into 2 separate lines:

```bash
"H02881
",Meibomian gland dysfunction right upper eyelid,Meibomian gland dysfunction right upper eyelid,
```

## The Goal

Take into consideration all of the edge-cases listed above and make the sample data fit into the following columns:

```
CODE,SHORT DESCRIPTION (VALID ICD-10 FY2024),LONG DESCRIPTION (VALID ICD-10 FY2024),NF EXCL
```

Where `NF EXCL` may or may not be present in the data and could be a blank column.

Example:

```bash
ABC123, "Testing, one", "Testing, two",
```

should be transformed into:

```bash
ABC123, "Testing - one", "Testing - two",
```

## Bash Script implementation (in-progress)

Assuming that the `.csv` is named `ICD-10-codes.csv`.

`normalizer.sh` will take in the input `.csv` file and an output `.csv` file.

```bash
./normalizer.sh ICD-10-codes.csv ICD-10-codes-final.csv
```
