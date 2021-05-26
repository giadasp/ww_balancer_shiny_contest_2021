library(ggplot2)
library(dplyr)
library(dutchmasters)

create_plot <- function(data, village_ids, roles, var) {
  cat("\ncreate_plot")
  if (length(village_ids) > 0) {
    if (var != "weights") {
      plot_columns(data, village_ids, roles, var)
    } else{
      plot_weights(data, village_ids, roles)
    }
  }
}

convert_list_of_roles_in_dt <- function (roles, village_ids, n_players) {
  cat("\nconvert_list_of_roles_in_dt")
  #print(roles)
  new_roles <- lapply(roles, function(x){c(x, rep(NA, n_players-length(x)+1))})
  #df <- bind_cols(lapply(roles, function(x){c(x, rep(NA, n_players-length(x)+1))}),.name_repair = "unique")
  #print(new_roles)
  df <- as.data.frame(do.call(cbind, new_roles))
  df <- df[1:(nrow(df)-1),]
  df <- data.frame(df)
  names(df) <- village_ids
  return(df)
}


plot_columns <- function(data, village_ids, roles, var) {
  data_var <- as.character(data[[var]])
  n_villages <- length(village_ids)
  n <- c()
  var_data <- c()
  village_name <- c()
  
  for (v in 1:n_villages) {
    roles_v <- roles[[v]]
    n_v <- data$n[data$role %in% roles_v]
    n <- c(n, n_v)
    var_data <- c(var_data, data_var[data$role %in% roles_v])
    village_name <-
      c(village_name, rep(paste("village", village_ids[v], sep = " "), length(n_v)))
  }
  
  df <- data.frame(village = factor(village_name, levels = unique(village_name)),
                   x = var_data,
                   n = n)
  names(df) <- c("village", var, "n")

  df2 <- df %>% 
    count(!!as.name(var), village, wt = n) %>%
    group_by(!!as.name(var))
  
  return(
    ggplot(df2, aes(
      x = village,
      y = n,
      fill = !!as.name(var)
    )) +
      geom_bar(stat = "identity", position = 'stack') +
      scale_fill_dutchmasters(palette = "view_of_Delft") +
      ylim(0, NA) +
      theme(
        text = element_text(size = 14),
        axis.text.x = element_text(angle = 45, hjust = 1)
      )
  )
}

plot_weights <- function(data, village_ids, roles) {
  cat("\nplot_weights")
  n_villages <- length(village_ids)
  weights_names <-
    names(data)[grepl("w_" , names(data))]
  
  factions <- substr(weights_names, 3, 100)
  
  n <- c()
  village_name <- c()
  weights_sum <- c()
  village_factions <- c()
  
  for (v in 1:n_villages) {
    n_v <- data$n[data$role %in% roles[[v]]]
    data_v <- data[data$role %in% roles[[v]], ]
    factions_v <- unique(data_v$faction)
    which_weights <- which(factions %in% factions_v)
    data_weights_v <- colSums(data_v[weights_names[which_weights]])
    weights_sum <- c(weights_sum, data_weights_v)
    village_factions <- c(village_factions, names(data_weights_v))
    village_name <-
      c(village_name, rep(paste("village", village_ids[v], sep = " "), length(names(data_weights_v))))
  }
  
  df <- data.frame(weight = weights_sum,
                   faction = factor(village_factions, levels = unique(village_factions)),
                   village = factor(village_name, levels = unique(village_name)))

  ggplot(df, aes(
    x = village,
    y = weight,
    group = faction,
    fill = faction)) +
    #geom_line(stat = "identity", size = 1.3) +
    #geom_point(size = 3) +
    #ylim(0, NA) +
    scale_fill_dutchmasters(palette = "view_of_Delft") +
    geom_bar(stat = "identity", position = 'dodge') +
    #scale_fill_brewer(palette = "Dark2") +
    theme(text = element_text(size = 14),
          axis.text.x = element_text(angle = 45, hjust = 1))
  
}
disable_all_but_id <- function(input, id){
  input_list <- reactiveValuesToList(input)
  toggle_inputs(input_list, F, id)
}
enable_all_but_id <- function(input, id){
  input_list <- reactiveValuesToList(input)
  toggle_inputs(input_list, T, id)
}
toggle_inputs <- function(input_list, enable_inputs=T, all_but_id=NULL){
  cat("\ntoggle_inputs")
  # Subset if only_buttons is TRUE.
  if(!is.null(all_but_id)){
    obj <- which(sapply(names(input_list),function(x) {
      !(x %in% all_but_id)}))
    input_list <- input_list[obj]
  }
  
  # Toggle elements
  for(x in names(input_list))
    if(enable_inputs){
      shinyjs::enable(x)} else {
        shinyjs::disable(x) }
}