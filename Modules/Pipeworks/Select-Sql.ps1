function Select-SQL
{
    <#
    .Synopsis
        Select SQL data
    .Description
        Select data from a SQL databsae
    .Example
        Select-Sql -FromTable ATable -Property Name, Day, Month, Year -Where "Year = 2005" -ConnectionSetting SqlAzureConnectionString
    .Example
        Select-Sql -FromTable INFORMATION_SCHEMA.TABLES -ConnectionSetting SqlAzureConnectionString -Property Table_Name -verbose
    .Example
        Select-Sql -FromTable INFORMATION_SCHEMA.TABLES -ConnectionSetting "Data Source=$env:ComputerName;Initial Catalog=Master;Integrated Security=SSPI;" -Property Table_Name -verbose
    .Link
        Add-SqlTable
    #>
    [CmdletBinding(DefaultParameterSetName='SQLQuery')]
    param(
    # The table containing SQL results
    [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true,ParameterSetName='SQLQuery')]    
    [Alias('SQL')]
    [string]$Query,

    # The table containing SQL results
    [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true,ParameterSetName='SimpleSQL')]
    [Alias('Table','From', 'TableName')]
    [string]$FromTable,

        # If set, will only return unique values.  This corresponds to the DISTINCT SQL qualifier.
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='SimpleSQL')]
    [Alias('Unique')]
    [Switch]$Distinct,

    # The properties to pull from SQL. If not set, all properties (*) will be returned
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='SimpleSQL')]
    [string[]]$Property,


    # The sort order of the returned objects
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='SimpleSQL')]
    [Alias('First')]
    [Uint32]$Top,

    # The sort order of the returned objects
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='SimpleSQL')]
    [Alias('Sort')]
    [string[]]$OrderBy,

    # If set, sorted items will be returned in descending order.  By default, if items are sorted, they will be in ascending order.
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='SimpleSQL')]
    [Switch]$Descending,

    # The where clause.
    [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='SimpleSQL')]
    [string]$Where,

    # A connection string or setting.    
    [Alias('ConnectionString', 'ConnectionSetting')]
    [string]$ConnectionStringOrSetting,

    # If set, will output the SQL
    [Switch]
    $OutputSql,

    # If set, will use SQL server compact edition    
    [Switch]
    $UseSQLCompact,

    # The path to SQL Compact.  If not provided, SQL compact will be loaded from the GAC    
    [string]
    $SqlCompactPath,    
    

    # If set, will use SQL lite    
    [Alias('UseSqlLite')]
    [switch]
    $UseSQLite,
    
    # The path to SQLite.  If not provided, SQLite will be loaded from Program Files
    [Alias('SqlLitePath')]
    [string]    
    $SqlitePath,
    
    
    # The path to a SQL compact or SQL lite database    
    [Alias('DBPath')]
    [string]
    $DatabasePath
    )

    begin {
        Set-StrictMode -Off
        if ($PSBoundParameters.ConnectionStringOrSetting) {
            if ($ConnectionStringOrSetting -notlike "*;*") {
                $ConnectionString = Get-SecureSetting -Name $ConnectionStringOrSetting -ValueOnly
            } else {
                $ConnectionString =  $ConnectionStringOrSetting
            }
            $script:CachedConnectionString = $ConnectionString
        } elseif ($script:CachedConnectionString){
            $ConnectionString = $script:CachedConnectionString
        } else {
            $ConnectionString = ""
        }
        if (-not $ConnectionString -and -not ($UseSQLite -or $UseSQLCompact)) {
            throw "No Connection String"
            return
        }

        if (-not $OutputSQL) {

            if ($UseSQLCompact) {
                if (-not ('Data.SqlServerCE.SqlCeConnection' -as [type])) {
                    if ($SqlCompactPath) {
                        $resolvedCompactPath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($SqlCompactPath)
                        $asm = [reflection.assembly]::LoadFrom($resolvedCompactPath)
                    } else {
                        $asm = [reflection.assembly]::LoadWithPartialName("System.Data.SqlServerCe")
                    }
                }
                $resolvedDatabasePath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($DatabasePath)
                $sqlConnection = New-Object Data.SqlServerCE.SqlCeConnection "Data Source=$resolvedDatabasePath"
                $sqlConnection.Open()
            } elseif ($UseSqlite) {
                if (-not ('Data.Sqlite.SqliteConnection' -as [type])) {
                    if ($sqlitePath) {
                        $resolvedLitePath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($sqlitePath)
                        $asm = [reflection.assembly]::LoadFrom($resolvedLitePath)
                    } else {
                        $asm = [Reflection.Assembly]::LoadFrom("$env:ProgramFiles\System.Data.SQLite\2010\bin\System.Data.SQLite.dll")
                    }
                }
                
                
                $resolvedDbPath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($DatabasePath)
                $sqlConnection = New-Object Data.Sqlite.SqliteConnection "Data Source=$resolvedDbPath"
                $sqlConnection.Open()
                
            } else {
                $sqlConnection = New-Object Data.SqlClient.SqlConnection "$connectionString"
                $sqlConnection.Open()
            }
            

        }
    }

    process {
        $dataSet = $null

        if ($PSCmdlet.ParameterSetName -eq 'SimpleSQL') {
            if (-not $Property) {
                $property = "*"
            }

            if ($Property -eq '*') {
                $propString = '*' 
            } else {
                if ($Property -like "*(*)*") {
                    $propString = "$($Property -join ',')"
                } else {
                    $propString = "`"$($Property -join '","')`""
                }
            }
        
            $sqlStatement = "SELECT $(if ($Top) { "TOP $Top" } ) $(if ($Distinct) { 'DISTINCT ' }) $propString FROM $FromTable $(if ($Where) { "WHERE $where"}) $(if ($OrderBy) { "ORDER BY $($orderBy -join ',') $(if ($Descending) { 'DESC'})"})".TrimEnd("\").TrimEnd("/")
            Write-Verbose "$sqlStatement"
         
            
        } elseif ($PSCmdlet.ParameterSetName -eq 'SQLQuery') {
            $sqlStatement = $Query    
        }

        $dataset = $null
        if ($OutputSql) {
            $sqlStatement
        } else {            
            if ($UseSQLCompact) {
                $sqlAdapter= New-Object "Data.SqlServerCE.SqlCeDataAdapter" ($sqlStatement, $sqlConnection)
                $sqlAdapter.SelectCommand.CommandTimeout = 0
                $dataSet = New-Object Data.DataSet
                $rowCount = $sqlAdapter.Fill($dataSet)
            } elseif ($UseSQLite) {
                $sqlAdapter= New-Object "Data.SQLite.SQLiteDataAdapter" ($sqlStatement, $sqlConnection)
                $sqlAdapter.SelectCommand.CommandTimeout = 0
                $dataSet = New-Object Data.DataSet
                $rowCount = $sqlAdapter.Fill($dataSet)
            } else {
                $sqlAdapter= New-Object "Data.SqlClient.SqlDataAdapter" ($sqlStatement, $sqlConnection)
                $sqlAdapter.SelectCommand.CommandTimeout = 0
                $dataSet = New-Object Data.DataSet
                $rowCount = $sqlAdapter.Fill($dataSet)
            }
            
        }

        


        if ($dataSet) {        
            foreach ($t in $dataSet.Tables) {
            
                foreach ($r in $t.Rows) {
                    
                    if ($r.pstypename) {                    
                        $r.pstypenames.clear()
                        foreach ($tn in ($r.pstypename -split "\|")) {
                            if ($tn) {
                                $r.pstypenames.add($tn)
                            }
                        }
                        
                    }
                    $null = $r.psobject.properties.Remove("pstypename")
                
                    $r
                
                }
            }
        }

        
    }

    end {
         
        if ($sqlConnection) {
            $sqlConnection.Close()
            $sqlConnection.Dispose()
        }
        
    }
}
 
