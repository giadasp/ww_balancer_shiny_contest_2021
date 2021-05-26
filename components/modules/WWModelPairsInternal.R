import::here(R6Class, .from = R6)
import::here(.from = rcbc, cbc_solve, solution_status, column_solution)
WWModelPairsInternal <- R6Class(
  "WWModelPairsInternal",
  portable = FALSE,
  class = FALSE,
  cloneable = FALSE,
  private = list(
    mat = matrix(nrow = 0, ncol = 0),
    row_ub = c(),
    is_integer = c(),
    col_lb = c(),
    col_ub = c(),
    max = FALSE,
    cbc_args = list("SEC" = "20", "logLevel" = 0),
    obj = c(),
    n = 0L,
    n_f_s = 0L,
    n_f = 0L,
    n_pairs = 0L,
    nn_f = 0L,
    n_total = 0L,
    n_e_s = 0L,
    factions = c(),
    mandatory = c(),
    names_friend_sets = c(),
    friend_sets = data.frame(),
    names_enemy_sets = c(),
    enemy_sets = data.frame(),
    data_cleaned = data.frame(),
    weights = data.frame(),
    n_constraints = 0L,
    constraints_counter = 0L,
    result = NULL,
    int_solutions = matrix(nrow = 0, ncol = 0),
    n_sol = 10,
    new_solutions = matrix(nrow = 0, ncol = 0),
    n_generated_solutions = 0L,
    count_constraints = function(faction_constraints,
                                 constraints,
                                 n_factions) {
      cat("\ncount_constraints")
      #count how many faction constraints
      c <- 0
      for (fac in faction_constraints) {
        if (constraints[[fac]][["min"]] > 0) {
          c <- c + 1
        }
        if (constraints[[fac]][["max"]] > 0) {
          c <- c + 1
        }
      }
      private$n_constraints <- 2 +
        length(private$mandatory) +
        (as.integer(n_factions > 0) * 2) +
        c + #too many because only if >0 they are valid
        private$n_e_s + # enemy sets
        (private$n_f_s * 2) + # friend sets
        (private$n_f * 2) + # faction count aux
        ((3 + 3 * private$n) * private$n_pairs) + # faction pair cross prod
        (2 * (private$n_pairs)) + #add_objective
        nrow(private$int_solutions) + # remove previous villages
        11
    },
    init_lp_model = function() {
      cat("\ninit_lp_model")
      private$mat <-
        matrix(0, nrow = private$n_constraints, ncol = private$n_total)
      cat("\nn_total")
      cat("\n")
      cat(private$n_total)
      cat("\n")
      private$row_ub <- rep(0, private$n_constraints)
      private$is_integer <-
        c(FALSE, rep.int(TRUE, private$n_total - 1))
      private$col_lb <- rep.int(0, private$n_total)
      private$col_ub <- c(Inf, rep.int(1, private$n_total - 1))
      private$obj <- c(1L, rep.int(0, private$n_total - 1))
      private$new_solutions <-
        matrix(nrow = private$n_sol, ncol = private$n)
      private$cbc_args <- list("SEC" = "20", "logLevel" = 0)
      private$max <- FALSE
      private$int_solutions <- matrix(nrow = 0, ncol = private$n)
    },
    increase_constraints_counter = function(n = 1) {
      private$constraints_counter <- private$constraints_counter + n
    },
    decrease_constraints_counter = function(n = 1) {
      private$constraints_counter <- private$constraints_counter - n
    },
    solve_model = function() {
      cat("\nsolve_model")
      private$result <-
        cbc_solve(
          obj = private$obj,
          mat = private$mat[1:(private$constraints_counter - 1), ],
          is_integer = private$is_integer,
          row_ub = private$row_ub[1:(private$constraints_counter - 1)],
          max = private$max,
          col_lb = private$col_lb,
          col_ub = private$col_ub,
          cbc_args = private$cbc_args
        )
      
    },
    count_pairs = function(n) {
      result = 0
      for (i in 1:(n - 1)) {
        result <- result + i
      }
      return(result)
    },
    clean_data = function(data) {
      cat("\nclean_data")
      private$data_cleaned <- data[data$excluded != 1,]
      private$n <- nrow(private$data_cleaned)
    },
    set_weights_and_factions = function() {
      cat("\nset_weights_and_factions")
      weights_names <-
        names(private$data_cleaned)[grepl("w_" , names(private$data_cleaned))]
      factions_from_weights <- substr(weights_names, 3, 100)
      factions_from_roles <-
        setdiff(unique(private$data_cleaned$faction), c(""))
      private$factions <-
        intersect(factions_from_weights, factions_from_roles)
      private$n_f <- length(private$factions)
      private$n_pairs <- private$count_pairs(private$n_f)
      private$nn_f <- private$n * private$n_pairs
      private$n_total <-
        1 + private$n + private$n_f_s + private$n_f + private$n_pairs + private$nn_f
      weights_col_names <- paste0("w_", private$factions)
      weights <- private$data_cleaned[weights_col_names]
      weights[is.na(weights)] <- 0.0
      private$weights <- weights
    },
    set_friend_sets = function() {
      cat("\nset_friend_sets")
      private$names_friend_sets <-
        names(private$data_cleaned)[grepl("friend_set" , names(private$data_cleaned))]
      private$n_f_s <- length(private$names_friend_sets)
      private$friend_sets <-
        data.frame(private$data_cleaned[, private$names_friend_sets])
      private$friend_sets[is.na(private$friend_sets)] <- 0
    },
    set_enemy_sets = function() {
      cat("\nset_enemy_sets")
      private$names_enemy_sets <-
        names(private$data_cleaned)[grepl("enemy_set" , names(private$data_cleaned))]
      private$n_e_s <- length(private$names_enemy_sets)
      private$enemy_sets <-
        data.frame(private$data_cleaned[, private$names_enemy_sets])
    },
    set_mandatory_roles = function() {
      cat("\nset_mandatory_roles")
      private$mandatory <-
        which(private$data_cleaned$mandatory == 1)
    },
    add_n_players_constraints = function(n_players) {
      n <- private$n
      cat("\nadd_n_players_constraints")
      private$mat[private$constraints_counter, 2:(n + 1)] <-
        private$data_cleaned$n
      private$row_ub[private$constraints_counter] <- n_players
      #row_names <- "n_players min"
      private$increase_constraints_counter()
      
      private$mat[private$constraints_counter, 2:(n + 1)] <-
        -private$data_cleaned$n
      private$row_ub[private$constraints_counter] <- -n_players
      #row_names <- c(#row_names, "n_players max")
      private$increase_constraints_counter()
      
    },
    add_n_factions_constraints = function(n_factions) {
      cat("\nadd_n_factions_constraints")
      
      idx_min <- 1 + private$n + private$n_f_s + 1
      idx_max <- idx_min + length(private$factions) - 1
      private$mat[private$constraints_counter, idx_min:idx_max] <- 1
      private$row_ub[private$constraints_counter] <- n_factions
      #row_names <- "n_players min"
      private$increase_constraints_counter()
      
      private$mat[private$constraints_counter, idx_min:idx_max] <-
        -1
      private$row_ub[private$constraints_counter] <- -n_factions
      #row_names <- c(#row_names, "n_players max")
      private$increase_constraints_counter()
      
    },
    add_mandatory_constraints = function() {
      cat("\nadd_mandatory_constraints")
      for (m in private$mandatory) {
        private$mat[private$constraints_counter, m + 1] <- -1
        private$row_ub[private$constraints_counter] <- -1
        #row_names <- c(#row_names, "mandatory roles")
        private$increase_constraints_counter()
      }
    },
    add_min_max_constraints = function(faction_constraints, constraints) {
      cat("\nadd_min_max_constraints")
      n <- private$n
      data_cleaned <- private$data_cleaned
      for (c in faction_constraints) {
        result = tryCatch({
          if (constraints[[c]][["min"]] > 0) {
            val <- data_cleaned$n
            val[data_cleaned$faction != c] <- 0
            private$mat[private$constraints_counter, 2:(n + 1)] <-
              -val
            private$row_ub[private$constraints_counter] <-
              -constraints[[c]][["min"]]
            #row_names <- c(#row_names, paste0(c," min constraint"))
            private$increase_constraints_counter()
          }
        }, warning = function(e) {
          print(e)
        }, error = function(e) {
          print(e)
        })
        result = tryCatch({
          if (constraints[[c]][["max"]] > 0) {
            val <- data_cleaned$n
            val[private$data_cleaned$faction != c] <- 0
            private$mat[private$constraints_counter, 2:(private$n + 1)] <-
              val
            private$row_ub[private$constraints_counter] <-
              constraints[[c]][["max"]]
            #row_names <- c(#row_names, paste0(c," max constraint"))
            private$increase_constraints_counter()
          }
        }, warning = function(e) {
          print(e)
        }, error = function(e) {
          print(e)
        })
        
      }
    },
    add_enemy_sets_constraints = function() {
      cat("\nadd_enemy_sets_constraints")
      n <- private$n
      
      if (private$n_e_s > 0) {
        for (e in 1:private$n_e_s) {
          private$mat[private$constraints_counter, 2:(n + 1)] <-
            private$enemy_sets[, e]
          private$row_ub[private$constraints_counter] <- 1
          private$increase_constraints_counter()
          #row_names <- c(#row_names, "enemy sets")
        }
      }
    },
    add_friend_sets_constraints = function(n_players) {
      cat("\nadd_friend_sets_constraint")
      friend_sets <- private$friend_sets
      n <- private$n
      L <- n_players
      for (f_s in 1:private$n_f_s) {
        private$mat[private$constraints_counter, 2:(n + 1)] <-
          friend_sets[, f_s]
        private$mat[private$constraints_counter, 1 + n + f_s] <- -L
        private$row_ub[private$constraints_counter] <- 0
        private$increase_constraints_counter()
        
        private$mat[private$constraints_counter, 2:(n + 1)] <-
          -friend_sets[, f_s]
        private$mat[private$constraints_counter, 1 + n + f_s] <- 1
        private$row_ub[private$constraints_counter] <- 0
        private$increase_constraints_counter()
      }
    },
    exclude_solutions = function(solutions) {
      n <- private$n
      if (nrow(solutions) > 0) {
        cat("\nexclude_solutions")
        for (s in 1:nrow(solutions)) {
          private$mat[private$constraints_counter, 2:(n + 1)] <-
            (2 * solutions[s,] - 1)
          private$row_ub[private$constraints_counter] <-
            sum(solutions[s,]) - 1
          private$increase_constraints_counter()
        }
      }
    },
    add_faction_count_aux = function() {
      cat("\nadd_faction_count_aux")
      n <- private$n
      n_f <- private$n_f
      n_f_s <- private$n_f_s
      
      first_faction_idx <- 1 + private$n + private$n_f_s
      
      for (f in 1:n_f) {
        isfactionf = as.integer(private$data_cleaned$faction == private$factions[f])
        
        private$mat[private$constraints_counter, 2:(n + 1)] <-
          -isfactionf
        private$mat[private$constraints_counter, first_faction_idx + f] <-
          1.1
        private$row_ub[private$constraints_counter] <- 0.1
        private$increase_constraints_counter()
        #row_names <- c(#row_names, paste0("v_", f, " first constr"))
        
        private$mat[private$constraints_counter, 2:(n + 1)] <-
          isfactionf
        private$mat[private$constraints_counter, first_faction_idx + f] <-
          0.9 - private$row_ub[1]
        private$row_ub[private$constraints_counter] <- 0.9
        private$increase_constraints_counter()
        #row_names <- c(#row_names, paste0("v_", f, " second constr"))
        
      }
    },
    add_cross_prod_faction_pair_aux = function() {
      cat("\nadd_cross_prod_faction_pair_aux")
      n <- private$n
      n_f <- private$n_f
      first_faction_idx <- 1 + n + private$n_f_s
      first_aux_pairs_idx <- first_faction_idx + n_f
      first_aux_prod_idx <- first_aux_pairs_idx + private$n_pairs
      
      c_1 <- 1
      c_2 <- 1
      
      local_mat <-
        matrix(
          0,
          nrow = private$n_constraints - private$constraints_counter,
          ncol = private$n_total
        )
      local_row_ub <-
        rep(0, private$n_constraints - private$constraints_counter)
      mat_yff <- matrix(nrow = (2 * n), ncol = 1)
      local_constraints_counter <- 1
      for (f in 1:(n_f - 1)) {
        for (f_1 in (f + 1):n_f) {
          idx_yff <- first_aux_pairs_idx + c_1
          
          local_mat[c(local_constraints_counter:(local_constraints_counter +
                                                   2)), idx_yff] <- c(1, 1, -1)
          local_mat[c(local_constraints_counter,
                      local_constraints_counter + 2), (first_faction_idx + f)] <- c(-1, 1)
          local_mat[c((local_constraints_counter + 1),
                      local_constraints_counter + 2), (first_faction_idx + f_1)] <-
            c(-1, 1)
          
          local_row_ub[local_constraints_counter:(local_constraints_counter +
                                                    2)] <- c(0, 0, 1)
          
          local_constraints_counter <- local_constraints_counter + 3
          
          # int_c_2_min <- first_aux_prod_idx + 1
          # int_c_2_max <- first_aux_prod_idx + n
          for (r in 1:n) {
            local_mat[c(local_constraints_counter:(local_constraints_counter + 2)), (first_aux_prod_idx + c_2)] <-
              c(1, 1, -1)
            local_mat[c(local_constraints_counter,
                        local_constraints_counter + 2), idx_yff] <- c(-1, 1)
            local_mat[c((local_constraints_counter + 1),
                        local_constraints_counter + 2), (1 + r)] <- c(-1, 1)
            local_row_ub[local_constraints_counter:(local_constraints_counter +
                                                      2)] <- c(0, 0, 1)
            
            local_constraints_counter <-
              local_constraints_counter + 3
            c_2 <- c_2 + 1
          }
          c_1 <- c_1 + 1
        }
      }
      local_constraints_counter <- local_constraints_counter - 1
      private$mat[private$constraints_counter:(private$constraints_counter +
                                                 (local_constraints_counter - 1)),] <-
        local_mat[1:(local_constraints_counter),]
      private$row_ub[private$constraints_counter:(private$constraints_counter +
                                                    (local_constraints_counter - 1))] <-
        local_row_ub[1:local_constraints_counter]
      private$increase_constraints_counter(local_constraints_counter + 1)
    },
    add_objective = function() {
      cat("\nadd_objective")
      n_f <- private$n_f
      n <- private$n
      
      first_aux_prod_idx <-
        1 + n + private$n_f_s + n_f + private$n_pairs
      weights <- private$weights
      c_2 <-  1
      for (f in 1:(n_f - 1)) {
        weights_f <- weights[, f]
        for (f_1 in (f + 1):n_f) {
          weights_f_1 <- weights[, f_1]
          private$mat[(private$constraints_counter:(private$constraints_counter + 1)), 1] <-
            c(-1, -1)
          private$row_ub[(private$constraints_counter:(private$constraints_counter + 1))] <-
            c(0, 0)
          
          weights_diff <- weights_f - weights_f_1
          
          idx_min <- first_aux_prod_idx + c_2
          idx_max <- idx_min + (n - 1)
          private$mat[private$constraints_counter, (idx_min:idx_max)] <-
            weights_diff
          private$mat[(private$constraints_counter + 1), (idx_min:idx_max)] <-
            -weights_diff
          c_2 <- c_2 + n
          
          #row_names <- c(#row_names, paste0("pair ", f, " ", f_1, "first obj"))
          #row_names <- c(#row_names, paste0("pair ", f, " ", f_1, "second obj"))
          private$increase_constraints_counter(2)
        }
      }
      # write.table(private$mat[1:private$constraints_counter, ], file = "mat.csv")
      # write.table(private$row_ub[1:private$constraints_counter], file = "row_ub.csv")
      #
      # write.table(private$row_ub, file="row_ub.csv")
      
    },
    find_solutions = function(n_sol) {
      withProgress(message = 'Generate 10 villages...', value = 0, {
        n <- private$n
        new_solutions <- matrix(nrow = n_sol, ncol = n)
        s <- 1
        n_generated_solutions <- 0
        progress <- 0
        while (s <= n_sol) {
          private$solve_model()
          status <- solution_status(private$result)
          cat("\n")
          cat(status)
          cat("\n")
          if (status %in% c("optimal", "time_limit")) {
            solution <- column_solution(private$result)[2:(n + 1)]
            cat("\n")
            cat(solution)
            cat("\n")
            if (!is.null(solution)) {
              cat("\nmodel has solution")
              if (s > 1) {
                if (all(solution == new_solutions[s - 1,])) {
                  cat("\nsame solution as before")
                  s <- n_sol + 1
                }
              }
              if (s <= n_sol) {
                cat("\ndifferent solution")
                private$exclude_solutions(matrix(solution, nrow = 1, ncol = n))
                new_solutions[s,] <- solution
                s <- s + 1
                n_generated_solutions <- n_generated_solutions + 1
              }
              progress <- progress + 1 / n_sol
              
            } else{
              progress <- 1
              s <- n_sol + 1
            }
          } else{
            progress <- 1
            s <- n_sol + 1
          }
          setProgress(progress)
        }
        if (n_generated_solutions > 0) {
          new_solutions <-
            matrix(new_solutions[1:n_generated_solutions, ],
                   nrow = n_generated_solutions,
                   ncol = private$n)
          
        }
        private$n_generated_solutions <- n_generated_solutions
      })
      return(new_solutions)
    },
    append_solutions = function(solutions) {
      private$int_solutions <- rbind(private$int_solutions, solutions)
    },
    solutions_to_villages = function(solutions) {
      cat("\nsolutions_to_villages")
      n_sol <- nrow(solutions)
      new_villages <- matrix(nrow = n_sol, ncol = private$row_ub[1])
      for (s in 1:n_sol) {
        solution_s <-
          solutions[s,]
        new_villages_s <-
          private$data_cleaned$role[solution_s > 0]
        
        if (sum(new_villages_s[!is.na(new_villages_s)] == "Monk") > 0) {
          cat("\nextract Monk cards")
          n2 <- which(new_villages_s == "Monk")
          exc_roles <-
            setdiff(private$data_cleaned$role, new_villages_s)
          exc_roles <-
            sample(exc_roles, size = min(c(5, length(exc_roles))))
          
          new_villages_s[n2] <-
            paste(c("Monk(", paste(exc_roles, collapse = ', '), ")"), collapse = '')
        }
        new_villages[s, 1:sum(solution_s)] <- new_villages_s
      }
      new_villages <- as.data.frame(t(new_villages))
      return(new_villages)
    }
  ),
  public = list(
    initialize = function() {
      cat("\nInitialize internal lp model")
      private$mat <- matrix(nrow = 0, ncol = 0)
      private$row_ub <- c()
      private$is_integer <- c()
      private$col_lb <- c()
      private$col_ub <- c()
      private$max <- FALSE
      private$cbc_args <- list("SEC" = "20", "logLevel" = 0)
      private$obj <- c()
      private$n <- 0L
      private$n_f_s <- 0L
      private$n_f <- 0L
      private$n_pairs <- 0L
      private$nn_f <- 0L
      private$n_total <- 0L
      private$n_e_s <- 0L
      private$factions <- c()
      private$mandatory <- c()
      private$names_friend_sets <- c()
      private$friend_sets <- data.frame()
      private$names_enemy_sets <- c()
      private$enemy_sets <- data.frame()
      private$data_cleaned <- data.frame()
      private$weights <- data.frame()
      private$n_constraints <- 0
      private$constraints_counter <- 1L
      private$result <- c()
      private$int_solutions <- matrix(nrow = 0, ncol = 0)
      private$n_sol <- 10
      private$new_solutions <- matrix(nrow = 0, ncol = 0)
      private$n_generated_solutions <- 0L
      return(invisible(self))
    },
    build = function(data,
                     n_players,
                     n_factions,
                     faction_constraints,
                     constraints) {
      cat
      withProgress(message = 'Build model...', value = 0, {
        private$clean_data(data)
        private$set_friend_sets()
        private$set_weights_and_factions()
        private$set_mandatory_roles()
        private$set_enemy_sets()
        incProgress(1 / 10)
        private$count_constraints(faction_constraints, constraints, n_factions)
        private$init_lp_model()
        private$add_n_players_constraints(n_players)
        private$add_mandatory_constraints()
        if (n_factions > 0) {
          private$add_n_factions_constraints(n_factions)
        }
        if (ncol(private$friend_sets) > 0) {
          private$add_friend_sets_constraints(n_players)
        }
        private$add_min_max_constraints(faction_constraints, constraints)
        private$add_enemy_sets_constraints()
        incProgress(2 / 10)
        
        private$add_faction_count_aux()
        incProgress(2 / 10)
        
        private$add_cross_prod_faction_pair_aux()
        incProgress(3 / 10)
        
        private$add_objective()
        print(private$constraints_counter)
        private$exclude_solutions(private$int_solutions)
        incProgress(2 / 10)
        
        write.csv(private$mat, "mat.csv")
        
      })
    },
    is_built = function() {
      return(!is.null(private$result))
    },
    add_rows = function(n_rows) {
      private$mat <-
        rbind(private$mat, matrix(0, nrow = n_rows, ncol = ncol(private$mat)))
      private$row_ub <- c(private$row_ub, rep(0, n_rows))
    },
    generate_villages = function(n_villages) {
      cat("\ngenerating...")
      new_solutions <- private$find_solutions(n_villages)
      if (private$n_generated_solutions > 0) {
        private$append_solutions(new_solutions)
        new_villages <- private$solutions_to_villages(new_solutions)
      } else{
        new_villages <- data.frame()
      }
      return(new_villages)
    },
    get_n_generated_solutions = function() {
      return(private$n_generated_solutions)
    }
  )
)