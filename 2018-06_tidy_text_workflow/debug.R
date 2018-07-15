# `r if(file.exists("debug.R")) { source("debug.R"); I(grid) }`

debug <- TRUE 

if(debug) {
  grid <- '
<div class="guide horz" style="height: 0%; width: 100%; top: 10%; left: 0%"></div>
<div class="guide horz" style="height: 0%; width: 100%; top: 20%; left: 0%"></div>
<div class="guide horz" style="height: 0%; width: 100%; top: 30%; left: 0%"></div>
<div class="guide horz" style="height: 0%; width: 100%; top: 40%; left: 0%"></div>
<div class="middle-guide horz" style="height: 0%; width: 100%; top: 50%; left: 0%"></div>
<div class="guide horz" style="height: 0%; width: 100%; top: 60%; left: 0%"></div>
<div class="guide horz" style="height: 0%; width: 100%; top: 70%; left: 0%"></div>
<div class="guide horz" style="height: 0%; width: 100%; top: 80%; left: 0%"></div>
<div class="guide horz" style="height: 0%; width: 100%; top: 90%; left: 0%"></div>

<div class="guide vert" style="height: 100%; width: 0%; top: 0%; left: 10%"></div>
<div class="guide vert" style="height: 100%; width: 0%; top: 0%; left: 20%"></div>
<div class="guide vert" style="height: 100%; width: 0%; top: 0%; left: 30%"></div>
<div class="guide vert" style="height: 100%; width: 0%; top: 0%; left: 40%"></div>
<div class="middle-guide vert" style="height: 100%; width: 0%; top: 0%; left: 50%"></div>
<div class="guide vert" style="height: 100%; width: 0%; top: 0%; left: 60%"></div>
<div class="guide vert" style="height: 100%; width: 0%; top: 0%; left: 70%"></div>
<div class="guide vert" style="height: 100%; width: 0%; top: 0%; left: 80%"></div>
<div class="guide vert" style="height: 100%; width: 0%; top: 0%; left: 90%"></div>
'  
} else {
  grid <- ''  
}
