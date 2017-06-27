
#Set $WD to R wokring directory
$WD="C:\Users\trobinson\Documents\Presentations\Analyzing Big Data with Microsoft R"
$in_file="$WD\Data\yellow_tripdata_2016-01.csv"
$out_file="$WD\Data\nyc_sample.csv"

#Get-Content $in_file | Measure-Object –Line
#10906859

#Get the Header row containing the column Names
Get-Content $in_file -TotalCount 1 | Out-File -Encoding utf8 $out_file;

#Get ~1% of the total data as a sample of one month
Get-Content $in_file | where {$_.readcount -gt 1 } | Get-Random -count 130000 | Out-File -Encoding utf8 -Append $out_file;