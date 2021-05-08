<#
 .Synopsis
  Get the Cowin Slots Near Me.

 .Description
  This Function pulls CowinSlots Near Me  from Cowin APIs.

 .Parameter DistrictsToQuery
  Parameter to provide districtID.

 .Parameter Date
  Optional Paramaeter to Input date.

  .Parameter AgeLimitQuery
   Paramaeter to Perform query on AgeLimit.

   .Parameter EmailIDFrom
  Optional Paramaeter to Input EmailIDFrom.

   .Parameter EmailIDTo
  Optional Paramaeter to Input EmailIDTo.

   .Parameter SMTPServer
  Optional Paramaeter to Input SMTPServer Address.

.Example
 #To find the slots near me
  Get-CowinSlotsNearMe -DistrictsToQuery 652 -Date 10 -AgeLimitQuery 18 -EmailIDFrom xyz@fiction.com -EmailIDTo xyz@fiction.com

#>

function Get-CowinSlotsNearMe
{

[CmdletBinding()]
    param
    (
        
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]
        $DistrictsToQuery,
        [parameter(Mandatory=$false)]
        [String]
        $Date=(Get-Date -Format "dd"),
        [parameter(Mandatory=$true)]
        [String]
        $AgeLimitQuery="18",
        [parameter(Mandatory=$true)]
        [int32]
        $EmailIDFrom,
        [parameter(Mandatory=$false)]
        [String]
        $EmailIDTo,
        [parameter(Mandatory=$false)]
        [String]
        $SMTPServer

    )

	
    Process 
    {

     $results=@()
     
     $object=$DistrictsToQuery | Get-CowinSlotsbyCalender  | ?{$_.SlotsVacant -notlike '*0*' -and $_.AgeLimit -like "*$AgeLimitQuery*" } 
     $results += $object

     if($results.count -eq 0) {Write-Host "no result found" -ForegroundColor Red}
     else
     {
        Show-Notification -ToastTitle 'Cowin' -ToastText "Hurray, total slots found: $($results.count)"

        Try
            {
             Send-MailMessage -From '$EmailIDFrom' -To $EmailIDTo -Subject 'Available Cowin Slots' -Body $($results| select SlotsVacant,District,Date,Name,Address |ft | Out-String) -SmtpServer $SMTPServer -Port 25 -ErrorAction Stop
            }

        Catch
            {
             Write-Warning "Unable to Send email. `n $($_.exception.message)"
            }
        return $results | select SlotsVacant,District,Date,Name,Address,agelimit 
        }
    }

}