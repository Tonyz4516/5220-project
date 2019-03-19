rms <- readLines("delete_variable_identified_by_floris.txt")
drop_var <- sub("    del df\\['", "", rms)
drop_var <- sub("'\\].*", "", drop_var)
