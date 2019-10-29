function Parse-DNSDDomainInfo {
    ## based of https://www.leeholmes.com/blog/2015/01/05/extracting-tables-from-powershells-invoke-webrequest/
    Param (
        [parameter( Mandatory= $true,
        ValueFromPipelineByPropertyName = $true)]
        $domain,
        [parameter( Mandatory= $true,
        ValueFromPipelineByPropertyName = $true)]
        $ScanResults
    )
    ## Extract the tables out of the web request
    $tables   = @($ScanResults.ParsedHtml.getElementsByTagName("TABLE"))
    $DNSRows  = $($tables[0]).Rows
    $MXRows   = $($tables[1]).Rows
    $TXTRows  = $($tables[2]).Rows
    $HostRows = $($tables[3]).Rows
    ## Go through all of the rows in the table
    $DNSObject=@()
    ForEach ($row in $DNSRows) {
        $cells = @($row.Cells)
        $resultObject = [Ordered] @{ }
        $resultObject["nameserver"] = @(""  + $cells[0].InnerText).Trim().TrimEnd('.')
        $resultObject["ip"]         = @(("" + $cells[1].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[0]
        $resultObject["reversedns"] = @(("" + $cells[1].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[1]
        $resultObject["asn"]        = @(("" + $cells[2].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[0]
        $resultObject["country"]    = @(("" + $cells[2].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[1]
        $DNSObject +=[PSCustomObject] $resultObject
    }
    $MXObject=@()
    ForEach ($row in $MXRows) {
        $cells = @($row.Cells)
        $resultObject = [Ordered] @{ }
        $resultObject["priority"]   = @((""  + $cells[0].InnerText).Trim().split(" ") | Where-Object {$_ -notmatch "^$"})[0]
        $resultObject["mx"]         = @((("" + $cells[0].InnerText).Trim().split(" ") | Where-Object {$_ -notmatch "^$"})[1]).TrimEnd('.')
        $resultObject["ip"]         = @((""  + $cells[1].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[0]
        $resultObject["reversedns"] = @((""  + $cells[1].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[1]
        $resultObject["asn"]        = @((""  + $cells[2].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[0]
        $resultObject["country"]    = @((""  + $cells[2].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[1]
        $MXObject +=[PSCustomObject] $resultObject
    }
    $TXTObject=@()
    ForEach ($row in $TXTRows) {
        $TXTObject +=$row.InnerText
    }
    $Counter=0
    $resultObject = [Ordered] @{ }
    ForEach ($txt in $TXTObject) {
        $Counter++
        $resultObject[$("txt"+$counter)] = $txt
    }
    $TXTObject = [PSCustomObject]$resultObject
    $HostObject=@()
    ForEach ($row in $HostRows) {
        $cells = @($row.Cells)
        $resultObject = [Ordered] @{ }
        $resultObject["host"]       = @(( "" + $cells[0].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[0]
        $resultObject["services"]   = @(("" + $cells[0].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[(2..(("" + $cells[0].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"}).count)]
        $resultObject["ip"]         = @(("" + $cells[1].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[0]
        $resultObject["reversedns"] = @(("" + $cells[1].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[1]
        $resultObject["asn"]        = @(("" + $cells[2].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[0]
        $resultObject["country"]    = @(("" + $cells[2].InnerText).Trim().split([Environment]::NewLine) | Where-Object {$_ -notmatch "^$"})[1]
        $HostObject +=[PSCustomObject] $resultObject
    }
    Return $(New-Object psobject -Property @{domain=$domain;DNSObject=$DNSObject;MXObject=$MXObject;TXTObject=$TXTObject;HostObject=$HostObject})
}