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
library("patchwork")


# Define a function to calculate the volume 
get_vol <- function(diameters_km, thickness_m, num_sills=920.0)
{
  return(num_sills * (diameters_km/2.0)^2.0 * pi * (thickness_m / 1000.0))
}

# Calculate and make plot 
# First plot for observed sill complex volum
p1 <- tibble(diameters = seq(from=1, to=10, by=0.1)) %>% # Make a tibble with diams
  mutate("25 m" = get_vol(diameters, 25),        # Make the columns of vols for each sill thickness 
         "50 m" = get_vol(diameters, 50),
         "75 m" = get_vol(diameters, 75),
         "100 m" = get_vol(diameters, 100), 
         "150 m" = get_vol(diameters, 150), 
         "200 m" = get_vol(diameters, 200)) %>% 
  gather(thickness, volume, "25 m", "50 m", "75 m", "100 m", "150 m", "200 m") %>%          # Gather to make data long format
  mutate(label = if_else(diameters == max(diameters), 
                 as.character(thickness), NA_character_)) %>%   # Make a label at the end of the line
  ggplot(aes(x=diameters, y=volume, group=thickness)) + 
  geom_line() +
  geom_label(aes(label=label), na.rm=TRUE, label.size=0) +
  xlim(0,11) +
  scale_colour_discrete(guide = 'none') + 
  annotate("text", x = 10, y = 0.17e05, label = "Average\nsill thickness") +
  labs(x = "Average sill diameter (km)",
       y = bquote("Observed sill complex volume (" ~ km^3~")")) +
  theme_tufte(base_size = 16, base_family = "sansserif")


# Second plot for total sill complex volume 
# number of sills is 145,000 sq km * 0.05 sill area density = 7250 sills
p2 <- tibble(diameters = seq(from=1, to=10, by=0.1)) %>% # Make a tibble with diams
  mutate("25 m" = get_vol(diameters, 25, 7250),        # Make the columns of vols for each sill thickness 
         "50 m" = get_vol(diameters, 50, 7250),
         "75 m" = get_vol(diameters, 75, 7250),
         "100 m" = get_vol(diameters, 100, 7250), 
         "150 m" = get_vol(diameters, 150, 7250), 
         "200 m" = get_vol(diameters, 200, 7250)) %>% 
  gather(thickness, volume, "25 m", "50 m", "75 m", "100 m", "150 m", "200 m") %>%          # Gather to make data long format
  mutate(label = if_else(diameters == max(diameters), 
                         as.character(thickness), NA_character_)) %>%   # Make a label at the end of the line
  ggplot(aes(x=diameters, y=volume, group=thickness)) + 
  geom_line() +
  geom_label(aes(label=label), na.rm=TRUE, label.size=0) +
  xlim(0,11) +
  scale_colour_discrete(guide = 'none') + 
  annotate("text", x = 10, y = 1.325e05, label = "Average\nsill thickness") +
  labs(x = "Average sill diameter (km)",
       y = bquote("Total sill complex volume (" ~ km^3~")")) +
  theme_tufte(base_size = 16, base_family = "sansserif")


p1 + p2 + plot_annotation(tag_levels = "a")

ggsave("total_sill_vol.png", height = 5.5, width = 10, units="in", dpi = 600)
