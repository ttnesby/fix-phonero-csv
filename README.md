[![Netlify Status](https://api.netlify.com/api/v1/badges/76e82e8c-5eba-4cd0-bfab-a84b638a3b3c/deploy-status)](https://app.netlify.com/sites/phenomenal-babka-2ab4de/deploys)

# fix-phonero-csv

The repo contains an elm module that can be used to map the phonero csv files for compliance with expected CSV format of a given financial software.

See `./src/Upload.elm`

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

The downloaded file will be in `~/Downloads/<selected filename>-FIXED.csv`

# Netlify deployment

The [SPA is deployed on Netlify](https://torstein-nesby.netlify.app/).

## Redirects

One last things that you'll need to set up is the redirects for SPA. Since all the routing is done by the client side, the server needs to redirect to the root for every request.
Which means all the path needs to be redirected to index.html.

See `./netlify.toml`





