if ($env:TEAMCITY_VERSION) {
  # When PowerShell is started through TeamCity's Command Runner, the standard
  # output will be wrapped at column 80 (a default). This has a negative impact
  # on service messages, as TeamCity quite naturally fails parsing a wrapped
  # message. The solution is to set a new, wider output width. It will
  # only be set if TEAMCITY_VERSION exists, i.e., if started by TeamCity.
  try {
      $rawUI = (Get-Host).UI.RawUI
      $m = $rawUI.MaxPhysicalWindowSize.Width
      $rawUI.BufferSize = New-Object Management.Automation.Host.Size ([Math]::max($m, 500), $rawUI.BufferSize.Height)
      $rawUI.WindowSize = New-Object Management.Automation.Host.Size ($m, $rawUI.WindowSize.Height)
    } catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host "WARNING: Failed setting buffer size - $ErrorMessage"
  }
}

function Write-TCMessage {
   param
   (
     [string]
     $text,

     [string]
     $status = 'NORMAL',

     [string]
     $errorDetails
   )

  $messageAttributes = @{ text=$text; status=$status }

  if ($errorDetails) {
    $messageAttributes.errorDetails = $errorDetails
  }

  Write-TCWriteServiceMessage 'message' $messageAttributes
}

function Write-TCBlockOpened {
   param
   (
     [string]
     $name,

     [string]
     $description
   )

  $messageAttributes = @{ name=$name }

  if ($description) {
    $messageAttributes.description = $description
  }

  Write-TCWriteServiceMessage 'blockOpened' $messageAttributes
}

function Write-TCBlockClosed {
   param
   (
     [string]
     $name
   )

  Write-TCWriteServiceMessage 'blockClosed' @{ name=$name }
}

function Write-TCTestSuiteStarted {
   param
   (
     [string]
     $name
   )

  Write-TCWriteServiceMessage 'testSuiteStarted' @{ name=$name }
}

function Write-TCTestSuiteFinished {
   param
   (
     [string]
     $name
   )

  Write-TCWriteServiceMessage 'testSuiteFinished' @{ name=$name }
}

function Write-TCTestStarted {
   param
   (
     [string]
     $name
   )

  Write-TCWriteServiceMessage 'testStarted' @{ name=$name }
}

function Write-TCTestFinished {
   param
   (
     [string]
     $name,

     [int]
     $duration
   )

  $messageAttributes = @{name=$name; duration=$duration}

  if ($duration -gt 0) {
    $messageAttributes.duration=$duration
  }

  Write-TCWriteServiceMessage 'testFinished' $messageAttributes
}

function Write-TCTestIgnored {
   param
   (
     [string]
     $name,

     [string]
     $message = ''
   )

  Write-TCWriteServiceMessage 'testIgnored' @{ name=$name; message=$message }
}

function Write-TCTestOutput {
   param
   (
     [string]
     $name,

     [string]
     $output
   )

  Write-TCWriteServiceMessage 'testStdOut' @{ name=$name; out=$output }
}

function Write-TCTestError {
   param
   (
     [string]
     $name,

     [string]
     $output
   )

  Write-TCWriteServiceMessage 'testStdErr' @{ name=$name; out=$output }
}

function Write-TCTestFailed {
   param
   (
     [string]
     $name,

     [string]
     $message,

     [string]
     $details = '',

     [string]
     $type = '',

     [string]
     $expected = '',

     [string]
     $actual = ''
   )

  $messageAttributes = @{ name=$name; message=$message; details=$details }

  if (![string]::IsNullOrEmpty($type)) {
    $messageAttributes.type = $type
  }

  if (![string]::IsNullOrEmpty($expected)) {
    $messageAttributes.expected=$expected
  }
  if (![string]::IsNullOrEmpty($actual)) {
    $messageAttributes.actual=$actual
  }

  Write-TCWriteServiceMessage 'testFailed' $messageAttributes
}

# See http://confluence.jetbrains.net/display/TCD5/Manually+Configuring+Reporting+Coverage
function Write-TCConfigureDotNetCoverage {
   param
   (
     [string]
     $key,

     [string]
     $value
   )

    Write-TCWriteServiceMessage 'dotNetCoverage' @{ $key=$value }
}

function Write-TCImportDotNetCoverageResult {
   param
   (
     [string]
     $tool,

     [string]
     $path
   )

  Write-TCWriteServiceMessage 'importData' @{ type='dotNetCoverage'; tool=$tool; path=$path }
}

# See http://confluence.jetbrains.net/display/TCD5/FxCop_#FxCop_-UsingServiceMessages
function Write-TCImportFxCopResult {
   param
   (
     [string]
     $path
   )

  Write-TCWriteServiceMessage 'importData' @{ type='FxCop'; path=$path }
}

function Write-TCImportDuplicatesResult {
   param
   (
     [string]
     $path
   )

  Write-TCWriteServiceMessage 'importData' @{ type='DotNetDupFinder'; path=$path }
}

function Write-TCImportInspectionCodeResult {
   param
   (
     [string]
     $path
   )

  Write-TCWriteServiceMessage 'importData' @{ type='ReSharperInspectCode'; path=$path }
}

function Write-TCImportNUnitReport {
   param
   (
     [string]
     $path
   )

  Write-TCWriteServiceMessage 'importData' @{ type='nunit'; path=$path }
}

function Write-TCImportJSLintReport {
   param
   (
     [string]
     $path
   )

  Write-TCWriteServiceMessage 'importData' @{ type='jslint'; path=$path }
}

function Write-TCPublishArtifact {
   param
   (
     [string]
     $path
   )

  Write-TCWriteServiceMessage 'publishArtifacts' $path
}

function Write-TCReportBuildStart {
   param
   (
     [string]
     $message
   )

  Write-TCWriteServiceMessage 'progressStart' $message
}

function Write-TCReportBuildProgress {
   param
   (
     [string]
     $message
   )

  Write-TCWriteServiceMessage 'progressMessage' $message
}

function Write-TCReportBuildFinish {
   param
   (
     [string]
     $message
   )

  Write-TCWriteServiceMessage 'progressFinish' $message
}

function Write-TCReportBuildStatus {
   param
   (
     [Object]
     $status = $null,

     [string]
     $text = ''
   )

  $messageAttributes = @{ text=$text }

  if (![string]::IsNullOrEmpty($status)) {
    $messageAttributes.status=$status
  }

  Write-TCWriteServiceMessage 'buildStatus' $messageAttributes
}

function Write-TCReportBuildProblem {
   param
   (
     [string]
     $description,

     [Object]
     $identity = $null
   )

  $messageAttributes = @{ description=$description }

  if (![string]::IsNullOrEmpty($identity)) {
    $messageAttributes.identity=$identity
  }

  Write-TCWriteServiceMessage 'buildProblem' $messageAttributes
}

function Write-TCSetBuildNumber {
   param
   (
     [string]
     $buildNumber
   )

  Write-TCWriteServiceMessage 'buildNumber' $buildNumber
}

function Write-TCSetParameter {
   param
   (
     [string]
     $name,

     [string]
     $value
   )

  Write-TCWriteServiceMessage 'setParameter' @{ name=$name; value=$value }
}

function Write-TCSetBuildStatistic {
   param
   (
     [string]
     $key,

     [string]
     $value
   )

  Write-TCWriteServiceMessage 'buildStatisticValue' @{ key=$key; value=$value }
}

function Write-TCEnableServiceMessages() {
  Write-TCWriteServiceMessage 'enableServiceMessages'
}

function Write-TCDisableServiceMessages() {
  Write-TCWriteServiceMessage 'disableServiceMessages'
}

function Write-TCCreateInfoDocument {
   param
   (
     [string]
     $buildNumber = '',

     [Object]
     $status = $true,

     [Object]
     $statusText = $null,

     [Object]
     $statistics = $null
   )

  $doc=New-Object xml;
  $buildEl=$doc.CreateElement('build');

  if (![string]::IsNullOrEmpty($buildNumber)) {
    $buildEl.SetAttribute('number', $buildNumber);
  }

  $buildEl=$doc.AppendChild($buildEl);

  $statusEl=$doc.CreateElement('statusInfo');
  if ($status) {
    $statusEl.SetAttribute('status', 'SUCCESS');
  } else {
    $statusEl.SetAttribute('status', 'FAILURE');
  }

  if ($statusText -ne $null) {
    foreach ($text in $statusText) {
      $textEl=$doc.CreateElement('text');
      $textEl.SetAttribute('action', 'append');
      $textEl.set_InnerText($text);
      $textEl=$statusEl.AppendChild($textEl);
    }
  }

  $statusEl=$buildEl.AppendChild($statusEl);

  if ($statistics -ne $null) {
    foreach ($key in $statistics.Keys) {
      $val=$statistics.$key
      if ($val -eq $null) {
        $val=''
      }

      $statEl=$doc.CreateElement('statisticsValue');
      $statEl.SetAttribute('key', $key);
      $statEl.SetAttribute('value', $val.ToString());
      $statEl=$buildEl.AppendChild($statEl);
    }
  }

  return $doc;
}

function Write-TCWriteInfoDocument {
   param
   (
     [xml]
     $doc
   )

  $dir=(Split-Path $buildFile)
  $path=(Join-Path $dir 'Write-TCinfo.xml')

  $doc.Save($path);
}

function Write-TCWriteServiceMessage {
   param
   (
     [string]
     $messageName,

     [Object]
     $messageAttributesHashOrSingleValue
   )

  function escape {
    param
    (
      [string]
      $value
    )

    ([char[]] $value |
        %{ switch ($_)
            {
                '|' { '||' }
                "'" { "|'" }
                "`n" { '|n' }
                "`r" { '|r' }
                '[' { '|[' }
                ']' { '|]' }
                ([char] 0x0085) { '|x' }
                ([char] 0x2028) { '|l' }
                ([char] 0x2029) { '|p' }
                default { $_ }
            }
        } ) -join ''
    }

  if ($env:TEAMCITY_VERSION) {
    if ($messageAttributesHashOrSingleValue -is [hashtable]) {
      $messageAttributesString = ($messageAttributesHashOrSingleValue.GetEnumerator() |
      %{ "{0}='{1}'" -f $_.Key, (escape $_.Value) }) -join ' '
      $messageAttributesString = " $messageAttributesString"
    } elseif ($messageAttributesHashOrSingleValue) {
      $messageAttributesString = (" '{0}'" -f (escape $messageAttributesHashOrSingleValue))
    }

    Write-Output "##teamcity[$messageName$messageAttributesString]"
  } else {
    if ($messageAttributesHashOrSingleValue -is [hashtable]) {
      $messageAttributesString = ($messageAttributesHashOrSingleValue.GetEnumerator() |
      %{ "{0}='{1}'" -f $_.Key, $_.Value }) -join ' '
      $messageAttributesString = " $messageAttributesString"
    } elseif ($messageAttributesHashOrSingleValue) {
      $messageAttributesString = (" '{0}'" -f ($messageAttributesHashOrSingleValue))
    }

    Write-Output "$messageName $messageAttributesString"
  }
}
function Get-TCBuildParams {
  $script:TCBuildParams = @{};
  $script:TCBuildConfig = @{};
  
  if (($env:TEAMCITY_BUILD_PROPERTIES_FILE -ne $null) -and (Test-Path $env:TEAMCITY_BUILD_PROPERTIES_FILE)) {
    $script:TCBuildParams = ConvertFrom-StringData (Get-Content $env:TEAMCITY_BUILD_PROPERTIES_FILE -Raw);
    $script:TCBuildConfig = ConvertFrom-StringData (Get-Content $($script:BuildParams['teamcity.configuration.properties.file']) -Raw)
  }
}

function Write-TCOpenCoverCoverage
{
  param
  (
    [String]
    $coverageResults
  )

  # classes
  $classesLine = $coverageResults | select-string -pattern "`r`nVisited Classes ([0-9]*) of ([0-9]*)" -allmatches

  if ($classesLine.Matches -ne $null)
  {
    $visitedClasses = $classesLine.Matches.Groups[1].Value
    $totalClasses = $classesLine.Matches.Groups[2].Value
    $classesCoverage = '{0:N2}' -f (($visitedClasses / $totalClasses)*100)

    Write-TCSetBuildStatistic -key 'CodeCoverageC' -value $classesCoverage
    Write-TCSetBuildStatistic -key 'CodeCoverageAbsCCovered' -value $visitedClasses
    Write-TCSetBuildStatistic -key 'CodeCoverageAbsCTotal' -value $totalClasses
  }

  # methods
  $methodsLine = $coverageResults | select-string -pattern "`r`nVisited Methods ([0-9]*) of ([0-9]*)" -allmatches

  if ($methodsLine.Matches -ne $null)
  {
    $visitedMethods = $methodsLine.Matches.Groups[1].Value
    $totalMethods = $methodsLine.Matches.Groups[2].Value
    $methodsCoverage = '{0:N2}' -f (($visitedMethods / $totalMethods)*100)

    Write-TCSetBuildStatistic -key 'CodeCoverageM' -value $methodsCoverage
    Write-TCSetBuildStatistic -key 'CodeCoverageAbsMCovered' -value $visitedMethods
    Write-TCSetBuildStatistic -key 'CodeCoverageAbsMTotal' -value $totalMethods
  }

  # sequence points / statements
  $pointsLine = $coverageResults | select-string -pattern "`r`nVisited Points ([0-9]*) of ([0-9]*)" -allmatches

  if ($pointsLine.Matches -ne $null)
  {
    $visitedPoints = $pointsLine.Matches.Groups[1].Value
    $totalPoints = $pointsLine.Matches.Groups[2].Value
    $pointsCoverage = '{0:N2}' -f (($visitedPoints / $totalPoints)*100)

    Write-TCSetBuildStatistic -key 'CodeCoverageS' -value $pointsCoverage
    Write-TCSetBuildStatistic -key 'CodeCoverageAbsSCovered' -value $visitedPoints
    Write-TCSetBuildStatistic -key 'CodeCoverageAbsSTotal' -value $totalPoints
  }

  # branches
  $branchesLine = $coverageResults | select-string -pattern "`r`nVisited Branches ([0-9]*) of ([0-9]*)" -allmatches

  if ($branchesLine.Matches -ne $null)
  {
    $visitedBranches = $branchesLine.Matches.Groups[1].Value
    $totalBranches = $branchesLine.Matches.Groups[2].Value
    $branchesCoverage = '{0:N2}' -f (($visitedBranches / $totalBranches)*100)

    Write-TCSetBuildStatistic -key 'CodeCoverageB' -value $branchesCoverage
    Write-TCSetBuildStatistic -key 'CodeCoverageAbsBCovered' -value $visitedBranches
    Write-TCSetBuildStatistic -key 'CodeCoverageAbsBTotal' -value $totalBranches
  }
}
