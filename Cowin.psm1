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
   # To find all the States and their IDs
     Get-CowinStateID 
   

 .Example
    # To find a particular state and it's ID
      Get-CowinStateID -StateNametoQuery 'Delhi'

 .Example
    # To find stateid by passing multiple statename, propertybyvalue
      'uttar','west' | Get-CowinStateID

#>


function Get-CowinStateID
{
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
} #function closing

Export-ModuleMember -Function Get-CowinStateID

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
   # To find all districts in stateid 34
     Get-CowinDistrict -StateID 34
   

 .Example
    # To find a particular state and it's ID
      Get-CowinDistrict -DistrictNametoQuery 'Delhi' -stateid 9 | ft
    

 .Example
    #Get-CowinStateID -StateNametoQuery 'uttar' | Get-CowinDistrict | ft

 .Example
    #To pass multiple district IDs, propertybyvalue
    10,11,12 | Get-CowinDistrict | ft

 .Example
    #To pass multiple district IDs, propertybyname
     Get-CowinStateID | Get-CowinDistrict | ft
#>


function Get-CowinDistrict
{
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
} #end function

Export-ModuleMember -Function Get-CowinDistrict

<#
 .Synopsis
  Get the CowinSlotsByDate.

 .Description
  This Function pulls CowinSlotsByDate information from Cowin APIs.

 .Parameter districtID
  Parameter to provide districtID.

 .Parameter Date
  Optional Paramaeter to Input date.

.Example
 #To pass multiple districtid to the function
 651,652 | Get-CowinSlotsByDate | ft

.Example
 #To find the slots by agelimit 18 and districtid 652
 Get-CowinSlotsByDate -districtID 652 | ?{$_.agelimit -eq 18}

.Example
 #To find the slots available for district 652 starting on 10th of the month
 Get-CowinSlotsByDate -districtID 652 -Date 10 | ft 

.Example
 #To find the slots by districtname, stateid
 Get-CowinDistrict -DistrictNametoQuery 'delhi' -StateID 9 | Get-CowinSlotsByDate -Date 10 | ft 


#>


<#
 .Synopsis
  Get the CowinSlotsbyCalender.

 .Description
  This Function pulls CowinSlotsbyCalender information from Cowin APIs.

 .Parameter districtID
  Parameter to provide districtID.

 .Parameter Date
  Optional Paramaeter to Input date.

 .Example
 #To pass multiple districtid to the function
 651,652 | Get-CowinSlotsbyCalender | ft

.Example
 #To find the slots by agelimit 18 and districtid 652
 Get-CowinSlotsbyCalender -districtID 652 | ?{$_.agelimit -eq 18}

.Example
 #To find the slots available for district 652 starting from 10th of the month
  Get-CowinSlotsbyCalender -districtID 652 -Date 10 | ft  

.Example
 #To find the slots by districtname, stateid
 Get-CowinDistrict -DistrictNametoQuery 'delhi' -StateID 9 | Get-CowinSlotsbyCalender -Date 10 | ft 

#>


function Get-CowinSlotsbyCalender
{
	[CmdletBinding()]
    param
    (
        
        [parameter(Mandatory=$true,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1,900)]
        [int]
        $districtID,

        [parameter(Mandatory=$false)]
        [ValidateRange(0,31)]
        [int]
        $Date = (Get-Date -Format "dd")

    )


    Process 
    {       


           
            $results =@()
            $url="https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=$districtID&date=$Date-05-2021"
            
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

    

} #Function Closing


Export-ModuleMember -Function Get-CowinSlotsByDate

<#
 .Synopsis
  Get the CowinSlotsbyCalender.

 .Description
  This Function pulls CowinSlotsbyCalender information from Cowin APIs.

 .Parameter districtID
  Parameter to provide districtID.

 .Parameter Date
  Optional Paramaeter to Input date.

 .Example
 #To pass multiple districtid to the function
 651,652 | Get-CowinSlotsbyCalender | ft

.Example
 #To find the slots by agelimit 18 and districtid 652
 Get-CowinSlotsbyCalender -districtID 652 | ?{$_.agelimit -eq 18}

.Example
 #To find the slots available for district 652 starting from 10th of the month
  Get-CowinSlotsbyCalender -districtID 652 -Date 10 | ft  

.Example
 #To find the slots by districtname, stateid
 Get-CowinDistrict -DistrictNametoQuery 'delhi' -StateID 9 | Get-CowinSlotsbyCalender -Date 10 | ft 

#>


function Get-CowinSlotsbyCalender
{
	[CmdletBinding()]
    param
    (
        
        [parameter(Mandatory=$true,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1,900)]
        [int]
        $districtID,

        [parameter(Mandatory=$false)]
        [ValidateRange(0,31)]
        [int]
        $Date = (Get-Date -Format "dd")

    )


    Process 
    {       


           
            $results 
            $url="https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=$districtID&date=$Date-05-2021"
            #Write-Host "$url"
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
      {Write-Warning "Unable to Query Covid Gov API for PS Function Get-CowinSlotsbyCalender. `n $($_.exception.message)"}
     }
            
    } #Process Closing

    

} #Function Closing

Export-ModuleMember -Function Get-CowinSlotsbyCalender

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

Export-ModuleMember -Function Get-CowinSlotsNearMe

function Show-Notification {
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
}


Export-ModuleMember -Function Show-Notification