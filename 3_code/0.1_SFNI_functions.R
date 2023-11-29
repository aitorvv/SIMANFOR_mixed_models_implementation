#### Dominant Height ####

# Function 1
dominantHeight <- function(x, plotID="PLOT_ID") {
  if(plotID %in% names(x)) {
    PLOT_ID = unique(x[[plotID]])
    Ho = rep(NA, length(PLOT_ID))
    names(Ho) = PLOT_ID
    for(i in 1:length(PLOT_ID)) {
      Ho[i] = .domheight(x$h[x[[plotID]] ==PLOT_ID[i]],
                         x$dbh[x[[plotID]]  ==PLOT_ID[i]],
                         x$expan[x[[plotID]]  ==PLOT_ID[i]])
    }
    Hd <- data.frame(PLOT_ID, Ho)
    return(Hd)
  }
  return(.domheight(x$h, x$d, x$n))
}

# Function 2
.domheight<-function(h, d, n) {
  o <-order(d, decreasing=TRUE)
  h = h[o]
  n = n[o]
  ncum = 0 
  for(i in 1:length(h)) {
    ncum = ncum + n[i]
    if(ncum>100) return(sum(h[1:i]*n[1:i], na.rm=TRUE)/sum(h[1:i]*n[1:i]/h[1:i], na.rm=TRUE))
  }
  return(sum(h*n)/sum(n))
}


#### Dominant Height ####

# Function 1
DiametroDominante <- function(x, plotID = "PLOT_ID"){
  if(plotID %in% names(x)) {
    IDs = unique(x[[plotID]])
    Do = rep(NA, length(IDs))
    names(Do) = IDs
    for(i in 1:length(IDs)) {
      Do[i] = .DiametroDominante_2(x$d[x[[plotID]] == IDs[i]],
                                   x$dbh[x[[plotID]] == IDs[i]],
                                   x$expan[x[[plotID]] == IDs[i]])
    }
    Dd <- data.frame(IDs, Do)
    return(Dd)
  }
  return(.DiametroDominante_2(x$h, x$d, x$n))
}

# Function 2
.DiametroDominante_2 <- function(h, d, n){
  o <- order(d, decreasing=TRUE)
  d = d[o]
  n = n[o]
  ncum = 0 
  for(i in 1:length(d)){
    ncum = ncum + n[i]
    if(ncum>100) return(sum(d[1:i]*n[1:i], 
                            na.rm=TRUE)/sum(d[1:i]*n[1:i]/d[1:i], 
                                            na.rm=TRUE))
  }
  return(sum(d*n)/sum(n))
}