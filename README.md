[![Netlify Status](https://api.netlify.com/api/v1/badges/76e82e8c-5eba-4cd0-bfab-a84b638a3b3c/deploy-status)](https://app.netlify.com/sites/phenomenal-babka-2ab4de/deploys)

# fix-phonero-csv

The repo contains an elm module that can be used to map the phonero csv files for compliance with expected CSV format of a given financial software.

See `./src/FixCsv.elm`

## Single Page Application (SPA)

The logic of the SPA is
1. A button for uploading and re-mapping a csv file
2. The re-mapping of certain columns has one of two outcomes
3. `Success` - the mapped content is displayed as table with mapped columns highlighted
4. `Errors` - the error messages are displayed as table
5. In both outcomes, the new csv content or error messages can be downloaded
6. After downloading, the SPA is back to step 1. 

## CSV mapping logic

The mapping logic is found in `./src/Csv.elm`

The core of the mapping is a simple replace of the value in certain columns with a new value.

```elm
mapValue : Int -> String -> String
mapValue colNo existingValue =
    if List.member colNo [ 0, 1 ] then
        "0"

    else if List.member colNo [ 4, 5, 6 ] then
        "0.00"

    else if colNo == 16 then
        "\"\""

    else
        existingValue
```

A few test cases are found in `./tests/CsvTests.elm`

```zsh
elm-test

# Result
Compiling > Starting tests

elm-test 0.19.1-revision10
--------------------------

Running 11 tests. To reproduce these results, run: elm-test --fuzz 100 --seed 332162524374445


TEST RUN PASSED

Duration: 80 ms
Passed:   11
Failed:   0
```

## Build index.html

```zsh
elm make ./src/FixCsv.elm --optimize
```

## Downloaded file

A downloaded file will be in 
- `~/Downloads/<selected filename>-FIXED.csv` for successful CSV mapping
- `~/Downloads/<selected filename>-ERRORS.txt` for CSV mapping errors

# Netlify deployment

The [SPA is deployed on Netlify](https://torstein-nesby.netlify.app/).

## Redirects

One last things that you'll need to set up is the redirects for SPA. Since all the routing is done by the client side, the server needs to redirect to the root for every request.
Which means all the path needs to be redirected to index.html.

See `./netlify.toml`





