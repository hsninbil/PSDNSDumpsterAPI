Function Get-PSDNSDumpsterAPIDomainInfo {
    <#
    .SYNOPSIS
    Get domain info from DNSDumpster.
    .DESCRIPTION
    Get domain info from DNSDumpster. This functions expects a PSObject created by New-PSDNSDumpsterAPISession.
    .PARAMETER DNSDSession
    PSObject created by New-PSDNSDumpsterAPISession
    .EXAMPLE
    New-PSDNSDumpsterAPISession -Domain 'justin-p.me' | Get-PSDNSDumpsterAPIDomainInfo
    .NOTES
    Author: Justin Perdok, https://justin-p.me.
    Project: https://github.com/justin-p/PSDNSDumpsterAPI
    #>
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        $DNSDumpsterSession
    )
    Begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName) - Begin."
    }
    Process {
        Try {
            Try {
                Write-Verbose "$($FunctionName) - Processing '$($DNSDumpsterSession.body.targetip)'"
                $ScanResults = Invoke-WebRequest -Uri 'https://dnsdumpster.com' -Body $($DNSDumpsterSession.Body) -Method Post -WebSession $($DNSDumpsterSession.Session) -ContentType 'application/x-www-form-urlencoded' -Headers $($DNSDumpsterSession.Header)
            } Catch {
                Write-Error "$($FunctionName) - Unable to get results for domain '$($DNSDumpsterSession.body.targetip)' - $PSItem"
            }
        } Catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }
    }
    End {
        Write-Verbose "$($FunctionName) - End."
        Return (New-Object PSObject -Property @{ScanResults=$ScanResults;DomainName=$DNSDumpsterSession.body.targetip;DNSDumpsterSession=$DNSDumpsterSession})
    }
}