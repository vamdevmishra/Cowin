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


function Get-CowinSlotsByDate
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
            $url="https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByDistrict?district_id=$districtID&date=$date-05-2021"
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

    

} #function closing
