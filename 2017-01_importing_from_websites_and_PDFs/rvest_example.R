library(rvest)
cfs <- html("http://www.slmpd.org/cfs.aspx")

html_text(html_node(cfs,"tr:nth-child(1) td:nth-child(3)"))

html_table(html_nodes(cfs, "#gvData"))