# https://www.liamdbailey.com/post/making-beautiful-tables-with-gt/
library(dplyr)
library(scales)
library(gt)
packageVersion("gt")
#Load data and arrange in descending order of emissions
emissions_data <- read.csv(here::here("..2100/per-capita-co2-domestic-aviation.csv")) %>% 
  arrange(desc(Per.capita.domestic.aviation.CO2))

#Generate a gt table from head of data
head(emissions_data) %>% 
  gt()
(emissions_table <- head(emissions_data) %>% 
    gt() %>% 
    
    
    #Hide unwanted columns
    cols_hide(columns = c(Code)) %>% 
    #Rename columns
    cols_label(Entity = "Country",
               Per.capita.domestic.aviation.CO2 = "Per capita emissions (tonnes)") %>% 
    #Add a table title
    #Notice the `md` function allows us to write the title using markdown syntax (which allows HTML)
    tab_header(title = md("Comparison of per capita CO<sub>2</sub> emissions from domestic aviation (2018)")) %>% 
    #Add a data source footnote
    tab_source_note(source_note = "Data: Graver, Zhang, & Rutherford (2019) [via Our World in Data]"))
###
(emissions_table <- emissions_table %>% 
  #Format numeric column. Use `scale_by` to divide by 1,000. (Note: we'll need to rename the column again)
  fmt_number(columns = c(Per.capita.domestic.aviation.CO2),
             scale_by = 1000) %>%
  #Our second call to cols_label overwrites our first
  cols_label(Per.capita.domestic.aviation.CO2 = "Per capita emissions (kg)"))
###
(emissions_table <- emissions_table %>% 
    #Apply new style to all column headers
    tab_style(
      locations = cells_column_labels(columns = everything()),
      style     = list(
        #Give a thick border below
        cell_borders(sides = "bottom", weight = px(3)),
        #Make text bold
        cell_text(weight = "bold")
      )
    ) %>% 
    #Apply different style to the title
    tab_style(
      locations = cells_title(groups = "title"),
      style     = list(
        cell_text(weight = "bold", size = 24)
      )
    ))
##Apply our palette explicitly across the full range of values so that the top countries are coloured correctly
min_CO2 <- min(emissions_data$Per.capita.domestic.aviation.CO2)
max_CO2 <- max(emissions_data$Per.capita.domestic.aviation.CO2)
emissions_palette <- col_numeric(c("#FEF0D9", "#990000"), domain = c(min_CO2, max_CO2), alpha = 0.75)

(emissions_table <- emissions_table %>% 
    data_color(columns = c(Per.capita.domestic.aviation.CO2),
               colors = emissions_palette))
####
(emissions_table <- emissions_table %>% 
    #All column headers are capitalised
    opt_all_caps() %>% 
    #Use the Chivo font
    #Note the great 'google_font' function in 'gt' that removes the need to pre-load fonts
    opt_table_font(
      font = list(
        google_font("Chivo"),
        default_fonts()
      )
    ) %>%
    #Change the width of columns
    cols_width(c(Per.capita.domestic.aviation.CO2) ~ px(150),
               c(Entity) ~ px(400)) %>% 
    tab_options(
      #Remove border between column headers and title
      column_labels.border.top.width = px(3),
      column_labels.border.top.color = "transparent",
      #Remove border around table
      table.border.top.color = "transparent",
      table.border.bottom.color = "transparent",
      #Reduce the height of rows
      data_row.padding = px(3),
      #Adjust font sizes and alignment
      source_notes.font.size = 12,
      heading.align = "left"
    ))
#### Bonus
emissions_table %>% 
  gt::text_transform(
    #Apply a function to a column
    locations = cells_body(c(flag_URL)),
    fn = function(x) {
      #Return an image of set dimensions
      web_image(
        url = x,
        height = 12
      )
    }
  ) %>% 
  #Hide column header flag_URL and reduce width
  cols_width(c(flag_URL) ~ px(30)) %>% 
  cols_label(flag_URL = "")
###
#To convert country codes
install.packages("countrycode")
library(countrycode)

flag_db <- read.csv("Country_Flags.csv") %>% 
  #Convert country names into 3-letter country codes
  mutate(Code = countrycode(sourcevar = Country, origin = "country.name", destination = "iso3c", warn = FALSE)) %>% 
  select(Code, flag_URL = ImageURL)

flag_data <- emissions_data %>% 
  left_join(flag_db, by = "Code") %>% 
  select(flag_URL, Entity, everything())

#We'll need to refit our table using this new data
#Code below with comments removed.
emissions_table <- head(flag_data) %>% 
  gt() %>% 
  cols_hide(columns = c(Code)) %>% 
  cols_label(Entity = "Country",
             Per.capita.domestic.aviation.CO2 = "Per capita emissions (tonnes)") %>% 
  tab_header(title = md("Comparison of per capita CO<sub>2</sub> emissions from domestic aviation (2018)")) %>% 
  tab_source_note(source_note = "Data: Graver, Zhang, & Rutherford (2019) [via Our World in Data]") %>% 
  fmt_number(columns = c(Per.capita.domestic.aviation.CO2),
             scale_by = 1000) %>%
  cols_label(Per.capita.domestic.aviation.CO2 = "Per capita emissions (kg)") %>% 
  tab_style(
    locations = cells_column_labels(columns = everything()),
    style     = list(
      cell_borders(sides = "bottom", weight = px(3)),
      cell_text(weight = "bold")
    )
  ) %>% 
  tab_style(
    locations = cells_title(groups = "title"),
    style     = list(
      cell_text(weight = "bold", size = 24)
    )
  ) %>% 
  data_color(columns = c(Per.capita.domestic.aviation.CO2),
             colors = emissions_palette) %>% 
  opt_all_caps() %>% 
  opt_table_font(
    font = list(
      google_font("Chivo"),
      default_fonts()
    )
  ) %>%
  cols_width(c(Per.capita.domestic.aviation.CO2) ~ px(150),
             c(Entity) ~ px(400)) %>% 
  tab_options(
    column_labels.border.top.width = px(3),
    column_labels.border.top.color = "transparent",
    table.border.top.color = "transparent",
    table.border.bottom.color = "transparent",
    data_row.padding = px(3),
    source_notes.font.size = 12,
    heading.align = "left")
###
emissions_table %>% 
  gt::text_transform(
    #Apply a function to a column
    locations = cells_body(c(flag_URL)),
    fn = function(x) {
      #Return an image of set dimensions
      web_image(
        url = x,
        height = 12
      )
    }
  ) %>% 
  #Hide column header flag_URL and reduce width
  cols_width(c(flag_URL) ~ px(30)) %>% 
  cols_label(flag_URL = "")
##### Bonus 2
continent_data <- flag_data %>% 
  #Convert iso3 codes to FIPS
  mutate(continent = countrycode(sourcevar = Code, origin = "iso3c", destination = "continent", warn = FALSE)) %>% 
  select(continent, flag_URL, Entity, Per.capita.domestic.aviation.CO2)
###
(emissions_table_continent <- continent_data %>%
    #Just take the top 5 from each continent for our example
    group_by(continent) %>% 
    slice(1:5) %>% 
    #Just show Africa and Americas for our example
    filter(continent %in% c("Africa", "Americas")) %>%
    #Group data by continent
    gt(groupname_col = "continent") %>% 
    #Add flag images as before
    gt::text_transform(
      locations = cells_body(c(flag_URL)),
      fn = function(x) {
        web_image(
          url = x,
          height = 12
        )
      }
    ) %>% 
    cols_width(c(flag_URL) ~ px(30)) %>% 
    cols_label(flag_URL = "") %>% 
    #Original changes as above.
    cols_label(Entity = "Country",
               Per.capita.domestic.aviation.CO2 = "Per capita emissions (tonnes)") %>% 
    tab_header(title = md("Comparison of per capita CO<sub>2</sub> emissions from domestic aviation (2018)")) %>% 
    tab_source_note(source_note = "Data: Graver, Zhang, & Rutherford (2019) [via Our World in Data]") %>% 
    fmt_number(columns = c(Per.capita.domestic.aviation.CO2),
               scale_by = 1000) %>%
    cols_label(Per.capita.domestic.aviation.CO2 = "Per capita emissions (kg)") %>% 
    tab_style(
      locations = cells_column_labels(columns = everything()),
      style     = list(
        cell_borders(sides = "bottom", weight = px(3)),
        cell_text(weight = "bold")
      )
    ) %>% 
    tab_style(
      locations = cells_title(groups = "title"),
      style     = list(
        cell_text(weight = "bold", size = 24)
      )
    ) %>% 
    data_color(columns = c(Per.capita.domestic.aviation.CO2),
               colors = emissions_palette) %>% 
    opt_all_caps() %>% 
    opt_table_font(
      font = list(
        google_font("Chivo"),
        default_fonts()
      )
    ) %>%
    cols_width(c(Per.capita.domestic.aviation.CO2) ~ px(150),
               c(Entity) ~ px(400)) %>% 
    tab_options(
      column_labels.border.top.width = px(3),
      column_labels.border.top.color = "transparent",
      table.border.top.color = "transparent",
      table.border.bottom.color = "transparent",
      data_row.padding = px(3),
      source_notes.font.size = 12,
      heading.align = "left",
      #Adjust grouped rows to make them stand out
      row_group.background.color = "grey"))
