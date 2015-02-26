
## ----libraries-----------------------------------------------------------
require("XML",quietly=TRUE)
require("selectr",quietly=TRUE)


## ----reindex-------------------------------------------------------------
# recreate index.html with updated article list
# assumes the path points to a folder structure
# that adheres to the miniblog naming convention
reindex <- function(path="./",base="",meta=NA){
	docpath <- paste(path,"index.html",sep="")

	if(file.exists(docpath)){
		doc <- htmlParse(docpath)

		# get sorted article metadata
	if(typeof(meta)!="list") 
		meta <- as.data.frame(
			metadata(paste(path,"posts/",sep=""),
					 paste(base,"posts/",sep="")
			)
		)
		p <- order(meta$mdate,decreasing=TRUE)

		# replace links to articles
		articles <- querySelector(doc,"div .articles")
		removeNodes(xmlChildren(articles))
		for(i in p){
			a <- newXMLNode("a", newXMLTextNode(meta$post[i]), attrs=c(
					href= paste("posts/",meta$relpath[i],sep=""),
					target="frontpost"
					)
				 )
			addChildren(articles,a)
			addChildren(articles,newXMLNode("br"))
		}
		
		# repoint front page article
		f <- querySelector(doc,".frontpost")
		removeAttributes(f,.attrs="src")
		addAttributes(f,src=paste("posts/",meta$relpath[p[1]],sep=""))
	} else warning(paste("Index file does not exist: ", docpath,sep=""))
	return(doc)
}


## ----metadata------------------------------------------------------------
# function to read metadata from posts
metadata <- function(path="./",base=""){
	# create a structure to hold info
	meta <- list(post="", relpath="", mdate=0, title="", 
				 author="",date="", description="", keywords="",
				 content="")
				
	# get list of post html files
	dirs <- list.dirs(path,recursive=FALSE,full.names=FALSE)
	postpaths <- paste(dirs,"/",dirs,".html",sep='')
	postfullpaths <- paste(path,postpaths,sep='')
	
	# extract meta data from each file
	for(i in 1:length(postfullpaths)){
		if(file.exists(postfullpaths[i])){
			meta$post[i] <- dirs[i]
			meta$relpath[i] <- postpaths[i]
			meta$mdate[i] <- file.info(postfullpaths[i])$mtime 
			doc <- htmlParse(postfullpaths[i])
			absolurl(doc,base=paste(base,dirs[i],"/",sep=""))
			xvalue <- querySelector(doc,"title")
			if(!is.null(xvalue)) meta$title[i] <- xmlValue(xvalue)
			meta$author[i] <- metaval(doc,"author")
			meta$date[i] <- metaval(doc,"date")
			meta$description[i] <- metaval(doc,"description")
			meta$keywords[i] <- metaval(doc,"keywords")
			
			# extract a clean-ish copy of the content
			body <- toString.XMLNode(querySelector(doc,"body"))
			body <- substr(body,7,nchar(body)-8)
			body <- gsub("&#13;","",body)
			body <- gsub("\x92","'",body)
			body <- gsub("[\x93-\x94]",'"',body)
			body <- gsub("\x96",'&mdash;',body)
			body <- gsub("\x85",'&#8230;',body)
			body <- gsub("[\x7f-\xff]",' ',body)
			g <- regexpr("<!--DISQUS",body)[1] - 1
			if(g>0) body <- substr(body,1,g)
			meta$content[i] <- body
		}
	}
	return(meta)	
}


## ----metavalue-----------------------------------------------------------
# get a single metadata value
metaval <- function(xdoc,meta){
			r <- ""
			xvalue <- querySelector(xdoc,paste("meta[name=",meta,"]",sep=""))
			if(!is.null(xvalue)) r <- xmlGetAttr(xvalue,"content",default="")
			return(r)
}


## ----absolurl------------------------------------------------------------
# convert links in an xml node like <body> to 
# absolute references, using a base url
absolurl <- function(xml,base=""){
	if(substr(base,nchar(base),nchar(base)) != "/") 
		base <- paste(base,"/",sep="")

	# expand and link (stylesheet) references
	links <- querySelectorAll(xml,"link")
	for(i in links){
		link <- xmlGetAttr(i,"href",default="")
		if(link != "" & substr(link,1,4) != "http"){
			removeAttributes(i,.attrs="href")
			addAttributes(i,href=paste(base,link,sep=""))
		}
	}

	# expand img links to absolute references
	imgs <- querySelectorAll(xml,"img")
	for(i in imgs){
		link <- xmlGetAttr(i,"src",default="")
		if(link != "" & substr(link,1,4) != "http"){
			removeAttributes(i,.attrs="src")
			addAttributes(i,src=paste(base,link,sep=""))
		}
	}
	
	# expand a a-links that do not have https or # prefix
	anchors <- querySelectorAll(xml,"a")
	for(i in anchors){
		link <- xmlGetAttr(i,"href",default="")
		if(link != "" & substr(link,1,4) != "http" 
		   & substr(link,1,1) !="#"){
			removeAttributes(i,.attrs="href")
			addAttributes(i,src=paste(base,link,sep=""))
		}
	}
}


## ----rssupdate-----------------------------------------------------------
# create rss feed
rssupdate <- function(filename,meta=NA,path=NA,base="",keyword=NA){
	# get sorted post metadata
	if(typeof(meta)!="list") 
		meta <- metadata(paste(path,"posts/",sep=""),base=base)
	meta <- as.data.frame(meta)
	if(!is.na(keyword)) p <- which(grepl(keyword,meta$keywords))
	else p <- 1:nrow(meta)
	
	# rss preamble
	doc <- xmlParse(paste(path,filename,sep=""))
	url <- xmlValue(querySelector(doc,"link"))
	if(substr(url,nchar(url),nchar(url)) != "/") url <- paste(url,"/",sep="")
	
	channel <- xmlParent(querySelector(doc,"item"))
	removeNodes(querySelectorAll(doc,"item"))
	
	# create new item nodes
	for(i in p){
		a <- newXMLNode("item")
		title <- newXMLNode("title", newXMLTextNode(meta$title[i]))
		link <- newXMLNode("link", newXMLTextNode(
			paste(url,"posts/",meta$relpath[i],sep="")
		))
		guid <- newXMLNode("guid", newXMLTextNode(
			paste(url,"posts/",meta$relpath[i],sep="")
		))
		pubDate <- newXMLNode("pubDate", newXMLTextNode(
			format(as.POSIXct(meta$date[i]),"%a, %d %b %Y %H:%M:%S %z")
		))
		description <- newXMLNode("description", newXMLTextNode(
			meta$description[i]
		))
		content <- newXMLNode("content:encoded", 
			newXMLTextNode(meta$content[i], cdata=TRUE
		))
		addChildren(channel,a)
		addChildren(a,kids = 
			list(title,link,guid,pubDate,description,content)
		)
	}
	return(doc)
}


## ----blogupdate----------------------------------------------------------
# rewrite the index.html page of the blog
# incl. making a backup copy 
blogupdate <- function(path="./",base=""){
	curdir <- getwd()
	setwd(path)
	file.copy(from="index.html",to="index.html.old",overwrite=TRUE)
	meta <- metadata(path="posts/",base=paste(base,"posts/",sep=""))
	doc <- reindex(path,meta=meta)
	saveXML(doc,"index.html")
	saveXML(rssupdate("template.xml",path=path,meta=meta),"all.xml")
	saveXML(rssupdate("template.xml",path=path,keyword="R-code",meta=meta),"rcode.xml")
	setwd(curdir)	
}


