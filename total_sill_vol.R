####################################################
############ Sill province volume calcs ############
####################################################

### This script plots a figure for the Rockall sills
### paper which provides estimates of the total vol
### of a sill complex with 920 sills, for different
### average sill thicknesses and diameters. 

# Load required packages
library("tidyverse")
library("ggrepel")
library("ggthemes")

# Define a function to calculate the volume 
get_vol <- function(diameters_km, thickness_m)
{
  num_sills = 920.0
  return(num_sills * (diameters_km/2.0)^2.0 * pi * (thickness_m / 1000.0))
}

# Calculate and make plot 
tibble(diameters = seq(from=1, to=50, by=1)) %>% # Make a tibble with diams
  mutate("50 m" = get_vol(diameters, 50),        # Make the columns of vols for each sill thickness 
         "100 m" = get_vol(diameters, 100), 
         "150 m" = get_vol(diameters, 150), 
         "200 m" = get_vol(diameters, 200), 
         "250 m" = get_vol(diameters, 250), 
         "300 m" = get_vol(diameters, 300), 
         "350 m" = get_vol(diameters, 350), 
         "400 m" = get_vol(diameters, 400)
         ) %>% 
  gather(thickness, volume, "50 m", "100 m", "150 m", "200 m", "250 m", 
         "300 m", "350 m", "400 m") %>%          # Gather to make data long format
  mutate(label = if_else(diameters == max(diameters), 
                 as.character(thickness), NA_character_)) %>%   # Make a label at the end of the line
  ggplot(aes(x=diameters, y=volume, group=thickness)) + 
  geom_line() +
  geom_label(aes(label=label), na.rm=TRUE, label.size=0) +
  xlim(0,55) +
  scale_colour_discrete(guide = 'none') + 
  annotate("text", x = 50, y = 8e05, label = "Average\nsill thickness") +
  labs(x = "Average sill diameter (km)",
       y = bquote("Total observed sill complex volume (" ~ km^3~")")) +
  theme_tufte(base_size = 14, base_family = "sansserif")
ggsave("total_sill_vol.png", height = 5, width = 7, units="in", dpi = 600)
