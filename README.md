# fix-phonero-csv

The repo contains an elm module that can be used to map the phonero csv files for compliance with expected CSV format of a given financial software.

See `./src/Map.elm`

## Single Page Application (SPA)

The logic of the SPA is
1. A button for uploading a csv file
2. The mapped content is displayed in a textarea
3. A button for downloading the mapped content

## Mapping logic

The core mapping logic is straight forward. 

```elm
mapValue : Int -> String -> String
mapValue colNo value =
    if colNo == 0 || colNo == 1 then
        "0"

    else if colNo == 4 || colNo == 5 || colNo == 6 then
        "0.00"

    else if colNo == 16 then
        "\"\""

    else
        value
```

## Build index.html

```zsh
elm make ./src/Map.elm --optimize
```

## Download file

The downloaded file will be in `~/Downloads/FIXED-phonera.csv`





