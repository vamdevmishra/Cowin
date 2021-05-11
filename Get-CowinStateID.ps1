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
} #function closing