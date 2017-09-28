#!/usr/bin/Rscript

#
# This program aims to crawl the website, parse the statistics, and store the data to the working dirctory 
# Setup crontab to the job regularly
#
suppressMessages(require(RSelenium))
suppressMessages(require(XML))

# Define your own working directory
working_dir <- "./" 

# Setup Selenium's chrome browser
remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4444L, browserName = "chrome") 
q <- remDr$open(silent=T)
q <- remDr$setImplicitWaitTimeout(milliseconds = 600000)
q <- remDr$setTimeout(type = "page load", milliseconds = 600000)
q <- remDr$setAsyncScriptTimeout(milliseconds = 600000)

tryCatch({

t <- 0

# Make 5 trials to crawl linkhk.com  
while (t < 5){
        remDr$navigate("http://www.linkhk.com/tc/parking/?did=&fk=&pc=&cpptid=")
        Sys.sleep(30)
        current_link <- remDr$getCurrentUrl()[[1]]  # Check current url 
        if (!grepl('login.',current_link)[1]){
                break   # If not unuusal , break the loop
        }
        t <- t + 1
}

# Scrol down (page down key 100 times) to the bottom of the page
for (i in 1:100){
        remDr$findElement("css", "body")$sendKeysToElement(list(key = "page_down"))
        Sys.sleep(1)
}

if (0){
	Sys.sleep(5)
        remDr$executeScript("window.scrollTo(0,document.body.scrollHeight);")
	Sys.sleep(5)
        remDr$executeScript("window.scrollTo(0,document.body.scrollHeight);")
        Sys.sleep(5)
        field <- remDr$findElements(using = "xpath", "//*[@node-type='feed_content']")
        Sys.sleep(5)
        field <- remDr$findElements(using = "xpath", "//*[@node-type='feed_content']")
}

# Extract the parking locations and the number 
name <- remDr$findElements(using = 'class', "desc-container")

n_tmp <- c()
for (i in 1:length(name)){
        n_f <- name[[i]]
        meta <- n_f$getElementAttribute("outerHTML")[[1]]
        n <- gregexpr('>.*?<',meta)
        n <- gsub('[><]','', sapply(1:length(n[[1]]),function(x){substr(meta,n[[1]][x],n[[1]][x]+attr(n[[1]],"match.length")[x]-1)}))
	nn <- n[!grepl('^[ ]',n)]
	if (length(nn)>=2){
        	n_tmp <- rbind(n_tmp,nn[1:2])
	}
}

# Save the data to a csv
currenttime <- system('date +"%Y%m%d-%H%M"',intern = TRUE)
write.csv(n_tmp,paste0(working_dir,currenttime,".csv"), row.names = FALSE)
q <- remDr$close()

}, error = function(e){
	print(n_tmp)  ## Print error message
})
