function Get-CowinDistrict
{

<#
 .Synopsis
  Get the CowinDistrictID.

 .Description
  This Function pulls CowinDistrictID information from Cowin APIs.

 .Parameter StateID
  Need StateID of the State.

 .Parameter DistrictNametoQuery
  Optional Paramaeter to Query DistrictID by DistrictName.

 .Example 
     Get-CowinDistrict -StateID 34
       # To find all districts in stateid 34
   

 .Example

      Get-CowinDistrict -DistrictNametoQuery 'Delhi' -stateid 9 | ft
       # To find a particular state and it's ID
    

 .Example
    Get-CowinStateID -StateNametoQuery 'uttar' | Get-CowinDistrict | ft

 .Example
    10,11,12 | Get-CowinDistrict | ft
    #To pass multiple district IDs, propertybyvalue

 .Example
     Get-CowinStateID | Get-CowinDistrict | ft
     #To pass multiple district IDs, propertybyname
#>

	[CmdletBinding()]
    param
    (
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [int[]]$StateID,
        [parameter(Mandatory=$false)]
        [String]
        $DistrictNametoQuery


    )


    Process 
    {
          $results =@()

         $url="https://cdn-api.co-vin.in/api/v2/admin/location/districts/$StateID"
         Try
         {
            $invokeresults=Invoke-RestMethod -uri $url -ErrorAction Stop
     

         if ($invokeresults.districts.Count -gt 0)
                                                                         {

         foreach($item in $invokeresults.districts)
                        {

                         $Object =           New-Object PSObject  -Property  @{
                         DistrictName        = $item.'district_name'
                         DistrictID          = $item.'district_id'

                         }

                         $results += $Object

                }
            if($DistrictNametoQuery)
                {
                 $results | ? {$_.DistrictName -like "*$DistrictNametoQuery*"} 
                }

            else
                    {
                    $results | select Districtid,Districtname 
                    }
    } #if $invokeresults.districts.Count -gt 0
        else 
        {
            Write-Warning "No Districts Found, Please check if you have entered correct StateID"
        }


                } #try closing

                Catch

                    {
             
                     Write-Warning "Unable to Query Covid Gov API for PS Function Get-CowinDistrict. `n $($_.exception.message)" 

                    } #catch closing


  
    } #end Process
} #function Closing Get-CowinDistrict


Export-ModuleMember -Function Get-CowinDistrict

Function Get-CowinSlotsbyCalender
{

<#
 .Synopsis
  Get the CowinSlotsbyCalender.

 .Description
  This Function pulls CowinSlotsbyCalender information from Cowin APIs.

 .Parameter districtID
  Parameter to provide districtID.

 .Parameter Date
  Optional Paramaeter to Input date(Please enter in dd-MM-yyyy format, if you don't enter it will pick current date.

 .Example
  651,652 | Get-CowinSlotsbyCalender | ft
  #To pass multiple districtid to the function
 

.Example
 Get-CowinSlotsbyCalender -districtID 652 | ?{$_.agelimit -eq 18}
 #To find the slots by agelimit 18 and districtid 652
 

.Example
 Get-CowinSlotsbyCalender -districtID 652 -Date 12-05-2021 | ft
 #To find the slots available for district 652 starting from 10th of the month
    

.Example
 Get-CowinDistrict -DistrictNametoQuery 'delhi' -StateID 9 | Get-CowinSlotsbyCalender | ft 
 #To find the slots by districtname, stateid
 
#>

	[CmdletBinding()]
    param
    (
        
        [parameter(Mandatory=$true,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1,900)]
        [int]
        $districtID,

        [parameter(Mandatory=$false)]
        [String]
        $Date = (Get-Date -Format "dd-MM-yyyy")

    )


    Process 
    {        
            $results =@()
            $url="https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=$districtID&date=$Date"
       Try
            {
            $invokeresults=Invoke-RestMethod -uri $url -ErrorAction Stop
            if (($invokeresults.centers).count -gt 0)
                {

                    foreach($item in $invokeresults.centers)
                    {

                            $Object =              New-Object PSObject -Property @{
                             Name                = $item.name
                             Address             = $item.address
                             CenterID            = $item.'center_id'
                             State               = $item.'state_name'
                             District            = $item.'district_name'
                             FeeType             =$item.'fee_type'
                             SlotsVacant         =$item.sessions.'available_capacity' -join ','
                             Vaccine             =$item.sessions.'vaccine' -join ','
                             Date                =$item.sessions.'date' -join ','
                             AgeLimit            =$item.sessions.'min_age_limit' -join ','
                            }

                            $results += $Object
                   }
            
                   return $results
      } #If ($invokeresults.sessions.centers.count -gt 0) Closing
      else {Write-Warning "No slots Found for DistrictID $districtID and Date $Date, Please check if you have entered correct Date/information !!"}
     } #try closing

     Catch 

     {
      Write-Warning "Unable to Query Covid Gov API for PS Function Get-CowinSlotsbyCalender. `n $($_.exception.message)"
     }
            
    } #Process Closing

    

} #Function Closing Get-CowinSlotsbyCalender

Export-ModuleMember -Function Get-CowinSlotsbyCalender

Function Get-CowinSlotsByDate
{

<#
 .Synopsis
  Get the CowinSlotsByDate.

 .Description
  This Function pulls CowinSlotsByDate information from Cowin APIs.

 .Parameter districtID
  Parameter to provide districtID.

 .Parameter Date
  Optional Paramaeter to Input date(Please enter in dd-MM-yyyy format, if you don't enter it will pick current date.

.Example
 651,652 | Get-CowinSlotsByDate | ft
 #To pass multiple districtid to the function

.Example
 Get-CowinSlotsByDate -districtID 652 | ?{$_.agelimit -eq 18}
 #To find the slots by agelimit 18 and districtid 652
 

.Example
 Get-CowinSlotsByDate -districtID 652 -Date 12-05-2021 | ft 
 #To find the slots available for district 652 starting on 10th of the month
 

.Example
 Get-CowinDistrict -DistrictNametoQuery 'delhi' -StateID 9 | Get-CowinSlotsByDate -Date 10 | ft
 #To find the slots by districtname, stateid
#>

	[CmdletBinding()]
    param
    (
        [parameter(Mandatory=$true,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1,900)]
        [int]
        $districtID,

        [parameter(Mandatory=$false)]
        [String]
        $Date = (Get-Date -Format "dd-MM-yyyy")

    )


    Process 
    {
            $results =@()
            $url="https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByDistrict?district_id=$districtID&date=$date"
      Try
      {
            $invokeresults=Invoke-RestMethod -uri $url -ErrorAction Stop


          if ($invokeresults.sessions.count -gt 0)
           {
             foreach($item in $invokeresults.sessions)
                {

                        $Object =              New-Object PSObject  -Property  @{
                         Name                = $item.name
                         Address             = $item.address
                         CenterID            = $item.'center_id'
                         State               = $item.'state_name'
                         District            = $item.'district_name'
                         FeeType             =$item.'fee_type'
                         SlotsVacant         =$item.'available_capacity'
                         Vaccine             =$item.'vaccine'
                         Date                =$item.'date'
                         AgeLimit            =$item.'min_age_limit'
                        }

                        $results += $Object
               } #foreach closing
            
            $results | select AgeLimit,Address,CenterID,Date,District,FeeType,Name,State,SlotsVacant,Vaccine
          } #if ($invokeresults.sessions.count -gt 0) Closing
          
          else {Write-Warning "No slots Found DistrictID $districtID and Date $Date, Please check if you have entered correct Date/information !!"}
          } #Try closing
          
          
         Catch
         {Write-Warning "Unable to Query Covid Gov API for PS Function Get-CowinSlotsByDate. `n $($_.exception.message)"}
    } #Process closing

    

} #function closing Get-CowinSlotsByDate

Export-ModuleMember -Function Get-CowinSlotsByDate

function Get-CowinSlotsNearMe
{

<#
 .Synopsis
  Get the Cowin Slots Near Me.

 .Description
  This Function pulls CowinSlots Near Me  from Cowin APIs.

 .Parameter DistrictsToQuery
  Parameter to provide districtID.

  .Parameter AgeLimitQuery
   Paramaeter to Perform query on AgeLimit.

   .Parameter EmailIDFrom
  Optional Paramaeter to Input EmailIDFrom.

   .Parameter EmailIDTo
  Optional Paramaeter to Input EmailIDTo.

   .Parameter SMTPServer
  Optional Paramaeter to Input SMTPServer Address.

.Example
 Get-CowinSlotsNearMe -DistrictsToQuery 652 -AgeLimitQuery 18 -EmailIDFrom xyz@fiction.com -EmailIDTo xyz@fiction.com
 #To find the slots near me

 .Example
 Get-CowinSlotsNearMe -DistrictsToQuery 651 -AgeLimitQuery 45 -EmailIDFrom "david@domain.com" -EmailIDTo "david@domain.com" -SMTPServer "smtphost.subdomain.forestname.domain.com"  | ft
  #To find the slots near me for agelimit45 and sendemail

#>

[CmdletBinding()]
    param
    (
        
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]
        $DistrictsToQuery,

        [parameter(Mandatory=$false)]
        $AgeLimitQuery="18",

        [parameter(Mandatory=$false)]
        [String]
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
             #Write-Host "sending mail" -ForegroundColor Green
             Send-MailMessage -From $EmailIDFrom -To $EmailIDTo -Subject 'Available Cowin Slots' -Body $($results| select SlotsVacant,District,Date,Name,Address,ageLimit |ft | Out-String) -SmtpServer $SMTPServer -Port 25 -ErrorAction Stop -Verbose
            }

        Catch
            {
             Write-Warning "Unable to Send email. `n $($_.exception.message)"
            }
        return $results | select SlotsVacant,District,Date,Name,Address,agelimit 
        }
    }

} #function closing Get-CowinSlotsNearMe

Export-ModuleMember -Function Get-CowinSlotsNearMe

Function Get-CowinStateID
{

<#
 .Synopsis
  Get the CowinStateID.

 .Description
  This Function pulls CowinStateID information from Cowin APIs.

 .Parameter StateID
  Need StateID of the State.

 .Parameter StateNametoQuery
  Optional Paramaeter to Query StateID by StateName.

 .Example 
  Get-CowinStateID
  # To find all the States and their IDs
      
 .Example
 Get-CowinStateID -StateNametoQuery 'Delhi'
    # To find a particular state and it's ID   

 .Example
  'uttar','west' | Get-CowinStateID
    # To find stateid by passing multiple statename, propertybyvalue
#>

	[CmdletBinding()]
    param
    (
        [parameter(ValueFromPipeline = $true)]
        [String[]]
        $StateNametoQuery

    )


    Process 
    {
      $results =@()

     $url="https://cdn-api.co-vin.in/api/v2/admin/location/states"
     Try
         {
         $invokeresults=Invoke-RestMethod -uri $url -ErrorAction Stop
     if ($invokeresults.states.count -gt 0)
     {
     foreach($item in $invokeresults.states)
            {

                    $Object =              New-Object PSObject  -Property  @{
                     Name                = $item.'state_name'
                     StateID             = $item.'state_id'

                     }

                     $results += $Object

            }
        if($StateNametoQuery)
            {
             $results | ? {$_.Name -like "*$StateNametoQuery*"}
            }

       else
                {
                $results | select StateID,Name
                }

                } #if $invokeresults.states -gt 0 closing

else {Write-Warning "No States Found, Please check if you have entered correct StateID or your internet connection is working fine !!"}
} #try closing

    Catch 
        {
           Write-Warning "Unable to Query Covid Gov API for PS Function Get-CowinStateID. `n $($_.exception.message)"
        }
    } #process closing
} #function closing Get-CowinStateID

Export-ModuleMember -Function Get-CowinStateID


Function Show-Notification {
    [cmdletbinding()]
    Param (
        [string]
        $ToastTitle,
        [string]
        [parameter(ValueFromPipeline)]
        $ToastText
    )

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

    $RawXml = [xml] $Template.GetXml()
    ($RawXml.toast.visual.binding.text|where {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
    ($RawXml.toast.visual.binding.text|where {$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText)) > $null

    $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $SerializedXml.LoadXml($RawXml.OuterXml)

    $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
    $Toast.Tag = "PowerShell"
    $Toast.Group = "PowerShell"
    $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)

    $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell")
    $Notifier.Show($Toast);

} #function closing Show-Notification


Export-ModuleMember -Function Show-Notification
