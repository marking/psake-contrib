Import-Module '.\teamcity.psm1' -DisableNameChecking -Force

Describe 'Write-TCMessage' {
    It "Writes ##teamcity[message text='Build log message.' status='NORMAL']" {
        Write-TCMessage 'Build log message.' | `
          Should BeExactly "##teamcity[message text='Build log message.' status='NORMAL']"
    }
    
    It "Writes ##teamcity[message text='Exception text' status='ERROR']" {
        Write-TCMessage 'Exception text' 'ERROR' | `
          Should BeExactly "##teamcity[message text='Exception text' status='ERROR']"
    }
    
    It "Writes ##teamcity[message text='Exception text' errorDetails='stack trace' status='ERROR']" {
        Write-TCMessage 'Exception text' 'ERROR' 'stack trace' | `
          Should BeExactly "##teamcity[message errorDetails='stack trace' status='ERROR' text='Exception text']"
    }
}

Describe 'Write-TCBlockOpened' {
    It "Writes ##teamcity[blockOpened name='MyServiceBlock']" {
        Write-TCBlockOpened 'MyServiceBlock' | `
          Should BeExactly "##teamcity[blockOpened name='MyServiceBlock']"
    }
    
    It "Writes ##teamcity[blockOpened name='MyServiceBlock' description='Service block description.']" {
        Write-TCBlockOpened 'MyServiceBlock' 'Service block description.' | `
          Should BeExactly "##teamcity[blockOpened name='MyServiceBlock' description='Service block description.']"
    }
}

Describe 'Write-TCBlockClosed' {
    It "Writes ##teamcity[blockClosed name='MyServiceBlock']" {
        Write-TCBlockClosed 'MyServiceBlock' | `
          Should BeExactly "##teamcity[blockClosed name='MyServiceBlock']"
    }
}

Describe 'Write-TCWriteServiceMessage' {
    It "Writes ##teamcity[message 'Single parameter message.']" {
        Write-TCWriteServiceMessage 'message' 'Single parameter message.' | `
          Should BeExactly "##teamcity[message 'Single parameter message.']"
    }
    
    It "Writes ##teamcity[message key='value']" {
        Write-TCWriteServiceMessage 'message' @{ key = 'value'} | `
          Should BeExactly "##teamcity[message key='value']"
    }
}

Describe 'Write-TCTestSuiteStarted' {
    It "Writes ##teamcity[testSuiteStarted name='suiteName']" {
        Write-TCTestSuiteStarted 'suiteName' | `
          Should BeExactly "##teamcity[testSuiteStarted name='suiteName']"
    }
}

Describe 'Write-TCTestSuiteFinished' {
    It "Writes ##teamcity[testSuiteFinished name='suiteName']" {
        Write-TCTestSuiteFinished 'suiteName' | `
          Should BeExactly "##teamcity[testSuiteFinished name='suiteName']"
    }
}

Describe 'Write-TCTestStarted' {
    It "Writes ##teamcity[testStarted name='testName']" {
        Write-TCTestStarted 'testName' | `
          Should BeExactly "##teamcity[testStarted name='testName']"
    }
}

Describe 'Write-TCTestFinished' {
    It "Writes ##teamcity[testFinished duration='0' name='testName'] when no duration is given" {
        Write-TCTestFinished 'testName' | `
          Should BeExactly "##teamcity[testFinished duration='0' name='testName']"
    }
    
    It "Writes ##teamcity[testFinished duration='0' name='testName'] when 0 duration is given" {
        Write-TCTestFinished 'testName' 0 | `
          Should BeExactly "##teamcity[testFinished duration='0' name='testName']"
    }
    
    It "Writes ##teamcity[testFinished duration='247' name='testName'] when 247 duration is given" {
        Write-TCTestFinished 'testName' 247 | `
          Should BeExactly "##teamcity[testFinished duration='247' name='testName']"
    }
    
    It "Writes ##teamcity[testFinished duration='-1' name='testName'] when duration is negative number" {
        Write-TCTestFinished 'testName' -1 | `
          Should BeExactly "##teamcity[testFinished duration='-1' name='testName']"
    }
}

Describe 'Write-TCTestIgnored' {
    It "Writes ##teamcity[testIgnored message='' name='testName']" {
        Write-TCTestIgnored 'testName' | `
          Should BeExactly "##teamcity[testIgnored message='' name='testName']"
    }
    
    It "Writes ##teamcity[testIgnored message='ignore comment' name='testName']" {
        Write-TCTestIgnored 'testName' 'ignore comment' | `
          Should BeExactly "##teamcity[testIgnored message='ignore comment' name='testName']"
    }
}

Describe 'Write-TCTestOutput' {
    It "Writes ##teamcity[testStdOut name='className.testName' out='text']" {
        Write-TCTestOutput 'className.testName' 'text' | `
          Should BeExactly "##teamcity[testStdOut name='className.testName' out='text']"
    }
}

Describe 'Write-TCTestError' {
    It "Writes ##teamcity[testStdErr name='className.testName' out='error text']" {
        Write-TCTestError 'className.testName' 'error text' | `
          Should BeExactly "##teamcity[testStdErr name='className.testName' out='error text']"
    }
}

Describe 'Write-TCTestFailed' {
    It "Writes ##teamcity[testFailed message='failure message' type='comparisonFailure' actual='actual value' expected='expected value' details='message and stack trace' name='MyTest.test2']" {
        Write-TCTestFailed 'MyTest.test2' 'failure message' 'message and stack trace' 'comparisonFailure' 'expected value' 'actual value' | `
          Should BeExactly "##teamcity[testFailed message='failure message' type='comparisonFailure' actual='actual value' expected='expected value' details='message and stack trace' name='MyTest.test2']"
    }
}

Describe 'Write-TCConfigureDotNetCoverage' {
    It "Writes ##teamcity[dotNetCoverage ncover3_home='C:\tools\ncover3']" {
        Write-TCConfigureDotNetCoverage 'ncover3_home' 'C:\tools\ncover3' | `
          Should BeExactly "##teamcity[dotNetCoverage ncover3_home='C:\tools\ncover3']"
    }
    
    It "Writes ##teamcity[dotNetCoverage partcover_report_xslts='file.xslt=>generatedFileName.html']" {
        Write-TCConfigureDotNetCoverage 'partcover_report_xslts' 'file.xslt=>generatedFileName.html' | `
          Should BeExactly "##teamcity[dotNetCoverage partcover_report_xslts='file.xslt=>generatedFileName.html']"
    }
}

Describe 'Write-TCImportDotNetCoverageResult' {
    It "Writes ##teamcity[importData type='dotNetCoverage' tool='ncover3' path='C:\BuildAgent\work\build1\results.xml']" {
        Write-TCImportDotNetCoverageResult 'ncover3' 'C:\BuildAgent\work\build1\results.xml' | `
          Should BeExactly "##teamcity[importData path='C:\BuildAgent\work\build1\results.xml' tool='ncover3' type='dotNetCoverage']"
    }
}

Describe 'Write-TCImportFxCopResult' {
    It "Writes ##teamcity[importData type='FxCop' path='C:\BuildAgent\work\results.xml']" {
        Write-TCImportFxCopResult 'C:\BuildAgent\work\results.xml' | `
          Should BeExactly "##teamcity[importData type='FxCop' path='C:\BuildAgent\work\results.xml']"
    }
}

Describe 'Write-TCImportDuplicatesResult' {
    It "Writes ##teamcity[importData type='DotNetDupFinder' path='C:\BuildAgent\work\results.xml']" {
        Write-TCImportDuplicatesResult 'C:\BuildAgent\work\results.xml' | `
          Should BeExactly "##teamcity[importData type='DotNetDupFinder' path='C:\BuildAgent\work\results.xml']"
    }
}

Describe 'Write-TCImportInspectionCodeResult' {
    It "Writes ##teamcity[importData type='ReSharperInspectCode' path='C:\BuildAgent\work\results.xml']" {
        Write-TCImportInspectionCodeResult 'C:\BuildAgent\work\results.xml' | `
          Should BeExactly "##teamcity[importData type='ReSharperInspectCode' path='C:\BuildAgent\work\results.xml']"
    }
}

Describe 'Write-TCImportNUnitReport' {
    It "Writes ##teamcity[importData type='nunit' path='C:\BuildAgent\work\results.xml']" {
        Write-TCImportNUnitReport 'C:\BuildAgent\work\results.xml' | `
          Should BeExactly "##teamcity[importData type='nunit' path='C:\BuildAgent\work\results.xml']"
    }
}

Describe 'Write-TCImportJSLintReport' {
    It "Writes ##teamcity[importData type='jslint' path='C:\BuildAgent\work\results.xml']" {
        Write-TCImportJSLintReport 'C:\BuildAgent\work\results.xml' | `
          Should BeExactly "##teamcity[importData type='jslint' path='C:\BuildAgent\work\results.xml']"
    }
}

Describe 'Write-TCPublishArtifact' {
    It "Writes ##teamcity[publishArtifacts 'artifacts\*.exe -> App.zip']" {
        Write-TCPublishArtifact 'artifacts\*.exe -> App.zip' | `
          Should BeExactly "##teamcity[publishArtifacts 'artifacts\*.exe -> App.zip']"
    }
}

Describe 'Write-TCReportBuildStart' {
    It "Writes ##teamcity[progressStart 'Compilation started']" {
        Write-TCReportBuildStart 'Compilation started' | `
          Should BeExactly "##teamcity[progressStart 'Compilation started']"
    }
}

Describe 'Write-TCReportBuildProgress' {
    It "Writes ##teamcity[progressMessage 'Build progress message']" {
        Write-TCReportBuildProgress 'Build progress message' | `
          Should BeExactly "##teamcity[progressMessage 'Build progress message']"
    }
}

Describe 'Write-TCReportBuildFinish' {
    It "Writes ##teamcity[progressFinish 'Build finished.']" {
        Write-TCReportBuildFinish 'Build finished.' | `
          Should BeExactly "##teamcity[progressFinish 'Build finished.']"
    }
}

Describe 'Write-TCReportBuildStatus' {
    It "Writes ##teamcity[buildStatus text='{build.status.text}, 10/10 tests passed' status='SUCCESS']" {
        Write-TCReportBuildStatus 'SUCCESS' '{build.status.text}, 10/10 tests passed' | `
          Should BeExactly "##teamcity[buildStatus text='{build.status.text}, 10/10 tests passed' status='SUCCESS']"
    }
    
    It "Writes ##teamcity[buildStatus text='{build.status.text}, 10/10 tests passed'] without optional status attribute." {
        Write-TCReportBuildStatus -text '{build.status.text}, 10/10 tests passed' | `
          Should BeExactly "##teamcity[buildStatus text='{build.status.text}, 10/10 tests passed']"
    }
}

Describe 'Write-TCReportBuildProblem' {
    It "Writes ##teamcity[buildProblem description='A problem occured.' identity='SOME_IDENTITY']" {
        Write-TCReportBuildProblem 'A problem occured.' 'SOME_IDENTITY' | `
          Should BeExactly "##teamcity[buildProblem description='A problem occured.' identity='SOME_IDENTITY']"
    }
    
    It "Writes ##teamcity[buildStatus text='A problem occured.'] without optional identity attribute." {
        Write-TCReportBuildStatus -text 'A problem occured.' | `
          Should BeExactly "##teamcity[buildStatus text='A problem occured.']"
    }
}

Describe 'Write-TCSetBuildNumber' {
    It "Writes ##teamcity[buildNumber '1.2.3_{build.number}-ent']" {
        Write-TCSetBuildNumber '1.2.3_{build.number}-ent' | `
          Should BeExactly "##teamcity[buildNumber '1.2.3_{build.number}-ent']"
    }
}

Describe 'Write-TCSetParameter' {
    It "Writes ##teamcity[setParameter value='value1' name='system.p1']" {
        Write-TCSetParameter 'system.p1' 'value1' | `
          Should BeExactly "##teamcity[setParameter value='value1' name='system.p1']"
    }
}

Describe 'Write-TCSetBuildStatistic' {
    It "Writes ##teamcity[buildStatisticValue key='unittests.count' value='19']" {
        Write-TCSetBuildStatistic 'unittests.count' '19' | `
          Should BeExactly "##teamcity[buildStatisticValue key='unittests.count' value='19']"
    }
}

Describe 'Write-TCEnableServiceMessages' {
    It 'Writes ##teamcity[enableServiceMessages]' {
        Write-TCEnableServiceMessages| `
          Should BeExactly '##teamcity[enableServiceMessages]'
    }
}

Describe 'Write-TCDisableServiceMessages' {
    It 'Writes ##teamcity[disableServiceMessages]' {
        Write-TCDisableServiceMessages | `
          Should BeExactly '##teamcity[disableServiceMessages]'
    }
}
