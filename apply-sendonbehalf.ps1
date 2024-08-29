<#
.DESCRIPTION
Assign send on behalf permissions using powershell.
.PARAMETER inCloud
A Boolean value if mailbox is on prem or in the cloud. $true for Exchange Online, $false for Exchange On Prem. $true is default.
.PARAMETER isMailbox
A Boolean value if the email address is a mailbox or a distribution group. $True is default
.PARAMETER mailbox
A String representing the name of the mailbox where we are applying the send on behalf permissions.

#>

#Does the mailbox/distribution group exist in Exchange online?
$inCloud = $true
#processes the script as a mailbox when true, processes as distributon group when false
$ismailbox = $true
#mailbox name
$mailbox = ''
#authenticated user with exchange online
$adminUser = ''
#on prem server. example: hostname.domain.com/powershell/
$svr = ""
#user to grant permission
#example "user@domain.com"
$users = @("")


switch ($inCloud) {
    $false { $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $svr -Authentication Kerberos
        Import-PSSession $Session -AllowClobber
        $end = 0
    }
    $true { Connect-ExchangeOnline -UserPrincipalName $adminUser
    $end = 1
        }
}


switch ($ismailbox){
    $true {
        write-host 'Running script for mailbox'
        get-mailbox $mailbox | Select Name, Alias, UserPrincipalName, PrimarySmtpAddress, @{l='SendOnBehalfOf';e={$_.GrantSendOnBehalfTo -join ";"}}
        foreach ($user in $users){
        set-mailbox $mailbox -GrantSendonBehalfto @{add=$user}
        Write-Host "Adding $user"
        }
        get-mailbox $mailbox | Select Name, Alias, UserPrincipalName, PrimarySmtpAddress, @{l='SendOnBehalfOf';e={$_.GrantSendOnBehalfTo -join ";"}}
    }
    $false {
        write-host 'Running script for distribution group'
        foreach ($user in $users) {
            Set-DistributionGroup $mailbox -GrantSendonBehalfto @{add=$user} -bypasssecuritygroupmanagercheck
            Write-Host "Adding $user"
        }
        Get-distributiongroup $mailbox | fl Name, *grant*
    }




}

#>
if ($end -eq 1){
    Write-host 'Disconnecting from Exchange Online'
    Disconnect-ExchangeOnline -Confirm:$false
}
elseif ($end -eq 0) {
    Write-host 'Disconnecting from Exchange Onprem'
    Remove-PSSession $Session
}
