library(tidyverse)

load_data <- function() {
    wide <- read_csv("data/patients_wide.csv", col_types = cols(.default = col_character()))    
}