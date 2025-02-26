####################################################################################

# ==== PRINT POSIBLE ANSWERE ====
function writeQuestion ([string]$Text, $Iter, $Alpha, $StartNumber)
{
    if ($Alpha -eq $true)
    {
        # Display of suggested answers in LETTER brackets
        Write-Host "    $([char]($Iter+65)))" -NoNewline -ForegroundColor Yellow
        Write-Host " $($Text)" -NoNewline
        return [string]([char]($Iter+65))
    }
    else
    {
        # Display of suggested answers in NUMBER brackets
        Write-Host "    $($Iter + $StartNumber))" -NoNewline -ForegroundColor Yellow
        Write-Host " $($Text)" -NoNewline
        return $Iter + $StartNumber
    }

}

####################################################################################

# ===== CHECKS THE CORRECTNESS OF THE ANSWER TO QUESTION X =====
function setConfiguration ($ConfigFile)
{
    # Try downloads the configuration as a dictionary
    try{
        return Get-Content $ConfigFile | ConvertFrom-Json -AsHashtable -ErrorAction Stop
    }
    catch {
        Write-Host ""
        Write-Host "There is problem with $ConfigFile" -ForegroundColor Yellow
        exit
    }
}

####################################################################################

# ==== DISPLAYS THE WRONG ANSWER FOR QUESTION y ====
function writeWrongY ([hashtable]$AnswereList)
{
    Write-Host -Object "Wrong answer"  -ForegroundColor Red
    Write-Host -Object $AnswereList.Values -ForegroundColor Green
    return $false
}

####################################################################################

# ==== DISPLAYS THE WRONG ANSWER FOR QUESTION X ====
function writeWrongX ([hashtable]$AnswereList)
{
    Write-Host -Object "Wrong answer"  -ForegroundColor Red

    $CorectVersion = "" #Where-Object -InputObject $AnswereList -FilterScript {$_.Values -eq "1"}

    foreach ($Item in $AnswereList.Keys)
    {
        if ($AnswereList.$Item -eq "1"){ $CorectVersion += "$Item " }
    }

    Write-Host -Object $CorectVersion -ForegroundColor Green
    return $false
}

####################################################################################

# ===== CHECKS THE CORRECTNESS OF THE ANSWER TO QUESTION X =====
function xQuestionHandler ([hashtable]$AnswereList, [hashtable]$QuestionList, $UserInput)
{
    # Returns an error for an empty input
    if ($UserInput -eq "")
    {
        return writeWrongX -AnswereList $AnswereList
    } 

    # Iterating through each possible answer
    foreach ($Item in $AnswereList.Keys)
    {
        # Returns an error for an invalid answer in input
        if ( $AnswereList.$Item -eq "0" -and $UserInput -match $QuestionList.$Item)
        {
            return writeWrongX -AnswereList $AnswereList
        }

        # Returns an error for the correct answer that is missing in input
        if ( $AnswereList.$Item -eq "1" -and $UserInput -notmatch $QuestionList.$Item)
        {
            return writeWrongX -AnswereList $AnswereList
        }
    }

    # Returns for a correct answer
    Write-Host -Object "Corect answer"  -ForegroundColor Green
    return $true
}

####################################################################################

# ===== CHECKS THE CORRECTNESS OF THE ANSWER TO QUESTION Y =====
function yQuestionHandler ([hashtable]$AnswereList, [hashtable]$QuestionList, $UserInput)
{
    # Returns an error for an empty input
    if ($UserInput -eq "")
    {
        return writeWrongY -AnswereList $AnswereList
    } 

    # Iterates over the characters in input
    for( $j = 0; $j -lt $UserInput.Length; $j++)
    {
        # Returns an error for an invalid character
        if ( $QuestionList.$("$($j+1)") -ne $UserInput[$j] )
        {
            return writeWrongY -AnswereList $AnswereList
        }
    }

    # Returns for a correct answer
    Write-Host -Object "Corect answer"  -ForegroundColor Green
    return $true
}

####################################################################################

# ===== DISPLAYS POSSIBLE ANSWERES FOR QUESTION X =====
function writeXQuestion ([hashtable]$AnswereList, $TextArray, $Alpha, $StartNumber)
{
    $QuestionList = [Ordered]@{}
    $Iter = 0

    # Iterates through the suggested answers in random order
    foreach ($Item in $(Get-Random -Shuffle -InputObject $AnswereList.Keys))
    {
        # Displays suggested answers
        $Position = writeQuestion -Text $TextArray[[int]$Item+1] -Iter $Iter -Alpha $Alpha -StartNumber $StartNumber
        Write-Host ""

        # Creating a projection between the question number and the displayed question number
        $QuestionList.[string]$Item = $Position
        $Iter++
    }
    Write-Host ""

    # Returns a list of projections
    return $QuestionList
}

####################################################################################

# ===== DISPLAYS POSSIBLE ANSWERES FOR QUESTION Y =====
function writeYQuestion ([hashtable]$AnswereList, $TextArray, $Alpha, $StartNumber)
{
    $QuestionList = [Ordered]@{}

    # Iterates through the list of correct answers
    for ($j = 2; $j -lt $AnswereList.Count+2; $j++)
    {
        # Divides the string with the suggested answers into an array
        $Line = $TextArray[$j] -split ";;"
        $Line = $Line[0..$($Line.Length-2)]

        # Determine from among the suggested answers the correct one
        $CorrectAnswer = $Line[[int]$AnswereList."$($j-1)"-49]

        # Sets the array fields in random order
        $Line = Get-Random -Shuffle -InputObject $Line

        # Iterates over array fields
        for ($k = 0; $k -lt $Line.Length; $k++)
        {
            # Displays suggested answers
            $Position = writeQuestion -Text $Line[$k] -Iter $k -Alpha $Alpha -StartNumber $StartNumber

            # Creating a projection between the correct question number and the displayed question number
            if ($CorrectAnswer -eq $Line[$k])
            {
                $QuestionList.$("$($j-1)") = [string]$Position
            }
        }
        Write-Host ""
    }
    Write-Host ""

    # Returns a list of projections
    return $QuestionList
}

####################################################################################

# ===== DISPLAYS SESSION INFORMATION =====
function writeSesionInformation ($Sample, [hashtable]$Dictionary, [int]$Lenght, [int]$Roud, [int]$StartLength)
{
    Write-Host $Sample.Name # Print filename
    Write-Host "$($Dictionary.$($Sample.Name))/$Roud" # Print number of repetitions / initial number of repetitions
    Write-Host "[$( $StartLength - $Lenght )/$StartLength]" # Print how many questions were made / total number
    Write-Host "done: $( [Math]::Round(( $StartLength - $Lenght ) / $StartLength,2 ))%" # Print % of questions completed
}

####################################################################################

# ===== CREATES A DICTIONARY OF TYPE [ANSWER NUMBER : CORRECTNESS] =====
function answereListGenerator ([string]$FirstLine, [int]$StartPoint)
{
    $AnswereList = [ordered]@{}

    # Iterates over the characters in the first line of the file
    for ($j = $StartPoint; $j -lt $FirstLine.Length; $j++)
    {
        # Add [answer number : correctness] to lists of correct answers
        $AnswereList.$([string]$($j-$StartPoint+1)) = $FirstLine[$j]
    }

    # Returns the list of correct answers
    return $AnswereList
}

####################################################################################

# ===== SUPPORTS A QUESTION OF TYPE X =====
function XQuestion ($TextArray, $Dictionary, $Sample, $Lenght, $StartLength, $Alpha, $StartNumber) 
{
    # Downloads the list of correct answers into the dictionary
    $AnswereList = answereListGenerator -FirstLine $TextArray[0] -StartPoint 1

    # Displaying the question
    Write-Host -Object $TextArray[1] -ForegroundColor Cyan
    Write-Host ""

    # Display of possible answers
    $QuestionList = writeXQuestion -AnswereList $AnswereList -TextArray $TextArray -Alpha $Alpha -StartNumber $StartNumber

    # Displays session information
    writeSesionInformation -Sample $Sample -Dictionary $Dictionary -Lenght $Lenght -Roud $Roud -StartLength $StartLength

    $UserInput = [string](Read-Host "Your answer")

    if ($UserInput[0] -eq ">")
    {
        return $UserInput
    }

    # Return TRUE for a correct answer
    return xQuestionHandler -AnswereList $AnswereList -QuestionList $QuestionList -UserInput $UserInput
}

####################################################################################

# ===== SUPPORTS A QUESTION OF TYPE F (FLASHCARD) =====
function FQuestion ($TextArray, $Dictionary, $Sample, $Lenght, $StartLength)
{
    # Displaying the question
    Write-Host -Object $TextArray[1] -ForegroundColor Cyan
    Write-Host ""

    # Displays session information
    writeSesionInformation -Sample $Sample -Dictionary $Dictionary -Lenght $Lenght -Roud $Roud -StartLength $StartLength

    # Downloading responses
    Read-Host "Press enter to"
    Write-Host ""

    # Displaying the correct answer
    Write-Host -Object $TextArray[2] -ForegroundColor Cyan

    # Checking whether the answer was correct
    $UserInput = [string](Read-Host "Your answere is corect (y/N)")
    Write-Host ""

    if ($UserInput[0] -eq ">")
    {
        return $UserInput
    }

    if ($UserInput -ieq "y")
    {
        # Returns TRUE for a correct answer
        Write-Host -Object "Corect answer"  -ForegroundColor Green
        return $true
    }
    else
    {
        # Returns FALSE for an incorrect answer
        Write-Host -Object "Wrong answer"  -ForegroundColor Red
        return $false
    }
}

####################################################################################

# ===== SUPPORTS A QUESTION OF TYPE Y =====
function YQuestion ($TextArray, $Dictionary, $Sample, $Lenght, $StartLength, $Alpha, $StartNumber)
{
    # Downloads the list of correct answers into the dictionary
    $AnswereList = answereListGenerator -FirstLine $TextArray[0] -StartPoint 2

    # Displaying the question
    Write-Host -Object $TextArray[1] -ForegroundColor Cyan
    Write-Host ""

    # Display of possible answers
    $QuestionList = writeYQuestion -AnswereList $AnswereList -TextArray $TextArray -Alpha $Alpha -StartNumber $StartNumber

    # Displays session information
    writeSesionInformation -Sample $Sample -Dictionary $Dictionary -Lenght $Lenght -Roud $Roud -StartLength $StartLength

    $UserInput = [string](Read-Host "Your answer")

    if ($UserInput[0] -eq ">")
    {
        return $UserInput
    }

    # Return TRUE for a correct answer
    return yQuestionHandler -AnswereList $AnswereList -QuestionList $QuestionList -UserInput $UserInput
}

####################################################################################

# ==== HANDLING OF PROGRAMME COMMANDS ====
function commandHandler ($Dictionary, $UserInput, $Path)
{
    if ($UserInput -match "w")
    {
        Write-Host ""
        Write-Host "Session saved" -ForegroundColor Green
        Write-Host ""
        ConvertTo-Json -InputObject $Dictionary > "$Path/save.json"
    }

    if ($UserInput -match "q")
    {
        exit
    }
}

####################################################################################

# ==== DOWNLOADING THE SAVE.JSON FILE OR SETTING UP AUTOMATICALLY ====
function setDictionary ($Path, $Files, $Roud)
{
    try {
        $Dictionary = Get-Content "$Path\save.json" -ErrorAction Stop | ConvertFrom-Json  -AsHashtable -ErrorAction Stop
        Write-Host ""
        Write-Host "File seva.json opened correctly" -ForegroundColor Yellow
        Write-Host ""
        return $Dictionary
    }
    catch {
        $Dictionary = @{}
        foreach($Item in $Files.Name)
        {
            $Dictionary.$Item = $Roud
        }

        return $Dictionary
    }
}

####################################################################################

# ==== CALCULATION OF THE STARTING NUMBER OF QUESTIONS ====
function calculateSize ($Dictionary)
{
    $Suma = 0
    foreach ($Item in $Dictionary.Values)
    {
        $Suma += [int]$Item
    }

    return $Suma
}

####################################################################################

# ==== MAIN PART OF PROGRAM ====

<#
.SYNOPSIS
This programme is used for flashcards and simple quizzes.
.PARAMETER Path
Specifies the path to the question folder,supports relative and absolute paths.
This parameter can be used as a pipeline.
.PARAMETER ConfigFile
Specifies the path to the configuration file. Files in JSON format are supported,
with config.json being the default.
.PARAMETER Roud
Determines the initial number of repetitions of a single question.
The default setting is for the correctness of the config.
.PARAMETER WrongAdd
Determines the number of repetitions added during an incorrect answer.
The default setting is for the correctness of the config.
.PARAMETER MaxAdd
Specifies the maximum number of repetitions that can be reached.    
The default setting is for the correctness of the config.
.PARAMETER Bulletin
Specifies the preferred type of bullet: count or letter. The programme is not case-sensitive.
Possible options are: num or alf. The default setting is for the correctness of the config. 
.PARAMETER StartNumber
Sets the start of scoring for numerical bulletin. Possible options are: 0 or 1.
The default setting is for the correctness of the config.
.INPUTS
System.Management.Automation.PathInfo
System.Object.String
.OUTPUTS
None
.LINK
https://github.com/Szym123/flashcard-app
#>
function flashcard-app
{
    param(
    [parameter(mandatory,ValueFromPipeline = $true)][string]$Path,
    [string]$ConfigFile = "$(Split-Path $MyInvocation.MyCommand.Path -Parent)/config.json",
    [int]$Roud = -1,
    [int]$WrongAdd = -1,
    [int]$MaxAdd = -1,
    [string][ValidateSet("", "num", "alp")]$Bulletin = "",
    [int][ValidateSet(-1,0,1)]$StartNumber = -1
    )

    Write-Host $(Split-Path $MyInvocation.MyCommand.Path -Parent)

    $Config = setConfiguration -ConfigFile $ConfigFile

    # Copying the configuration from the dictionary to the variables
    if ($Roud -eq -1){ $Roud = $Config."Roud" }
    if ($WrongAdd -eq -1){ $WrongAdd = $Config."WrongAdd" }
    if ($MaxAdd -eq -1){ $MaxAdd = $Config."MaxAdd" }
    if ($StartNumber -eq -1){ $StartNumber = $Config."StartNumber" }

    # Setting the bullet type
    if ($Bulletin -eq ""){ $Alpha = $Config."Alpha" }
    elseif ($Bulletin -eq "num"){ $Alpha = $false }
    elseif ($Bulletin -eq "alp"){ $Alpha = $true }

    # Downloads a list of .txt files
    $Files = Get-ChildItem -Path $Path | Where-Object {$_.Extension -eq ".txt"}

    # Creates a dictionary [File: Number of repetitions]
    $Dictionary = setDictionary -Path $Path -Files $Files -Roud $Roud

    $Length = calculateSize -Dictionary $Dictionary

    $StartLength =$Length

    # Iterates every 1 from the initial number of questions to 0
    while($Length -ne 0)
    {
        # Selection of a random question
        do {
            $Sample = Get-Random -InputObject $Files
        } while ($Dictionary.$($Sample.Name) -eq 0)

        # Downloading text from a file
        try {
            $TextArray = $(Get-Content $Sample) -split "\n"
        }
        catch {
            Write-Host "There is problem with $($Sample.Name)"
            continue
        }

        # Adaptation of the service to the type of question
        switch ($TextArray[0][0])
        {
            "X" { $IsWin = XQuestion -TextArray $TextArray -Dictionary $Dictionary -Sample $Sample -Lenght $Length -StartLength $StartLength -Alpha $Alpha -StartNumber $StartNumber}
            "F" { $IsWin = FQuestion -TextArray $TextArray -Dictionary $Dictionary -Sample $Sample -Lenght $Length -StartLength $StartLength }
            "Y" { $IsWin = YQuestion -TextArray $TextArray -Dictionary $Dictionary -Sample $Sample -Lenght $Length -StartLength $StartLength -Alpha $Alpha -StartNumber $StartNumber}
            Default {
                Write-Host "Undefine question $($Sample.Name)" -ForegroundColor Yellow
                break
            }
        }

        if ($IsWin.GetType().Name -eq "String")
        {
            $IsWin = [string]$IsWin
            $i += 1
            commandHandler -Dictionary $Dictionary -UserInput $IsWin -Path $Path
            continue
        }

        # Adds repetition of the question for failure
        if ($IsWin -eq $false -and $Dictionary.$($Sample.Name) -lt $MaxAdd)
        {
            $Length += $WrongAdd
            $Dictionary.$($Sample.Name) += $WrongAdd
        }

        # Removes repetition of the question for the winner
        if ($IsWin -eq $true)
        {
            $Dictionary.$($Sample.Name) -= 1
        }

        Write-Host ""
    }

    Write-Host "You win !!!" -ForegroundColor Green
    Write-Host ""
}

####################################################################################