library(pdftools)

download.file("http://www.usda.gov/oce/commodity/wasde/Secretary_Briefing.pdf",
              "Secretary_Briefing.pdf", mode = "wb")
txt <- pdf_text("Secretary_Briefing.pdf")

pg <- cat(txt[2])