# Race visualizer

Visualise data from all races.

# Requirements

The source folder `race_data_raw` must:

* Have 1 subfolder for each race. The folder is called YYYY-MM-DD_RACE_NAME
* Each subfolder must contain:
  * A `data.json` file
  * An `img` folder (optional)
  * An `img_modal` folder (optional)
  * A `report.md` file (optional)
  
This folder can be created from a template using the function `create_new_folder` from the file `inst/new_race.R`.

## data.json

```json
[
  {
    "race": "",
    "type": "",
    "distance": "",
    "position_overall": "",
    "position_category": "",
    "time": "",
    "date": "",
    "details": "",
    "breakdown": {
      "swim": "",
      "t1": "",
      "bike": "",
      "t2": "",
      "run": ""
    }
  }
]
```

* The breakdown folder is optional and its exact content depends on the race type. The example above is for a triathlon race.
* The details field is a link to the activity file, i.e. the Garmin Connect activity.
* `type` must be one of "run", "sprint triathlon", "standard triathlon", "aquathlon", "bike", "swim", "sprint duathlon", "triathlon". "triathlon" is used only for the centurion race. If I'll do more longer races, I'll add more race types.
* Distances are in the format <X>m, for meter based ones, <X>K for kilometer based one, <X>m/<X>K/<X>K for multisport events.

## img and img_modal folders
We cannot display full size images. This will take too much space in the UI and will make the app slow. The folder img contains smaller thumbnails (recommended with of 250px) which will be used for the `slickr` gallery. The folder `img_modal` contains larger versions of the same images (recommended width of 500px) that are used to display individual photos on demand.

Running the script in `inst/sync_folders.R` will take care of creating this images.

## report.md

This is a free text markdown where you can write your race report.

# Workflow

* Use the function `create_new_folder` from the file `inst/new_race.R` to create a new folder for a new race.
* Move this folder into your race_data_raw.
* Make sure the data.json and report.md have everything you want.
* Run `source('inst/sync_folder.R')` to sync `race_data_raw` with `race_data`.


# Publish in quarto

`quarto publish gh-pages`
