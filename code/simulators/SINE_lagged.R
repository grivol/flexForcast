n_iter=100
ar_param = 0.80
#n_obs_list = c(1000,2500,5000)
n_obs_list = c(5000)
lags=3

sine_ar.sim = function(n){
  
  #initial data point is distributed N(0,1)
  points = rnorm(3,0,1)
  sd <- 0.25
  
  # we will generate (n+order) points so as to remove the first (order) points
  for (i in 3:n){
    error_t = rnorm(1,0,sd)
    new_point = sin(pi*points[length(points)-2])^2+error_t
    points = c(points,new_point)
  }
  
  points = points[4:length(points)]
  return(points)
}

sine_ar_simulator = function(n_obs)
{
  data = sine_ar.sim(n_obs)
  data <- as.data.frame(data)
  colnames(data) = "y"
  return(data)
}


for (n_obs in n_obs_list) {
  
  this_simulator = partial(sine_ar_simulator,
                           n_obs=n_obs)
  this_loss = simulation_run(this_simulator, lags=lags, n_iter = n_iter)
  
  this_pbloss  = this_loss$pbloss
  this_cdeloss = this_loss$cdeloss
  
  write_rds(this_pbloss, paste0("../results/PBLOSS_SINElagged_",n_obs,"obs.rds"))
  write_rds(this_cdeloss, paste0("../results/CDELOSS_SINElagged_",n_obs,"obs.rds"))
  
  processed_loss = process_loss_outputs(this_pbloss,this_cdeloss)
  write_rds(processed_loss,paste0("../results/processed/SINElagged_",n_obs,"obs.rds"))
  gc()
}