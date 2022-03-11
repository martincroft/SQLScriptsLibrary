#Invoke-sqlcmd Connection string parameters
$params = @{'server'='localhost';'Database'='AdventureWorks2019'}
$SQLQuery='uspDemoProcedure'
Workflow RunParallelExecute
{
    $ServerName = "localhost"
    $DatabaseName = "AdventureWorks2019"
    $Procedure_Query = "select name from ProceduresToRun"
    $Procedure_List = (Invoke-Sqlcmd -Server $ServerName -Database $DatabaseName -Query $Procedure_Query)

    ForEach -Parallel -ThrottleLimit 12 ($Procedure in $Procedure_List.Name) 
    {
         
         start-process -NoNewWindow C:\SQLScriptsLibrary\SSMS\SQLScriptLibrary\SQLBits2022\run.bat 
    }
}
RunParallelExecute
cls
