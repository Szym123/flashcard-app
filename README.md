# Quizownik

This programme is used for flashcards and simple quizzes.

> [!IMPORTANT]
> If you want to use the built-in help use powershell **get-help**.

## Installation

Download this repository and access it using Powershell. Afterwards, run the following command to get the full path to the program:

```powershell
$(get-item .\flashcard-app.ps1).FullName
```

Then open the user profile file using notepad:

```powershell
notepad.exe $PROFILE
```

Finally, add the following line to it, where [...] will replace the previously obtained programme location:

```powershell
. [...]
```

## Parameters

- **Path** - specifies the path to the question folder, supports relative and absolute paths. This parameter can be used as a pipeline.

- **ConfigFile** - Specifies the path to the configuration file, supports relative and absolute paths. Files in **JSON** format are supported, with config.json being the default.

- **Roud** - Determines the initial number of repetitions of a single question. The default setting: -1 is for the correctness of the config.

- **WrongAdd** - Determines the number of repetitions added during an incorrect answer. The default setting: -1 is for the correctness of the config.

- **MaxAdd** - Specifies the maximum number of repetitions that can be reached. The default setting: -1 is for the correctness of the config.

> [!IMPORTANT]
> If **MaxAdd** is equal to **Roud** then no new question duplicates will be added..

- **Bulletin** - Specifies the preferred type of bullet: count or letter. The programme is not case-sensitive. Possible options are: 

  - **num** - number
  - **alf** - alphabetically

The default setting is for the correctness of the config. 

- **StartNumber** - Specifies the start of scoring for numerical bulletin. Possible options are: **0** or **1**. The default setting: -1 is for the correctness of the config.

## Config

```json
{
  "MaxAdd": 2,
  "WrongAdd": 0,
  "Roud": 1,
  "StartNumber": 1,
  "Alpha": false
}
```

- **MaxAdd** - specifies the maximum number of repetitions that can be reached.
- **WrongAdd** - determines the number of repetitions added during an incorrect answer.
- **Roud** - determines the initial number of repetitions of a single question.
- **StartNumber** - specifies the start of scoring for numerical bulletin, possible options are: **0** or **1**.
- **Alpha** - Specifies the preferred type of bullet: 
    - ``false`` - numer
    - ``true`` - alphabetically

## Command mode

The programme has a simple command mode implemented, which is started by typing **>** in the answer field followed by the selected commands without spaces:
- **w** - save current session
- **q** - exit the program without saving (works similar to ctrl+c)

> [!TIP]
> Commands can be combined in sequences.

## Supported question types

Each question must be stored as a separate .txt file, the programme iterates through the folder containing such files.

### Flashcard

1. The first line contains the letter ‘F’, which indicates the type of question.
2. The second line contains the first page of the flashcard from the question.
3. The third line contains the second page of the flashcard with the correct answer.

The handling of the question involves displaying the first page of the flashcard, after the user presses enter displaying the second page, and then asking the user if he or she has answered the question correctly.

```
F
Jakieś pytanie?
Druga strona
```

### Multiple-choice question

1. The first line contains:
    - the letter ‘X’, which indicates the type of question,
    - the numbers 0/1 (false/true) corresponding to the correctness of the answers given in lines 3 and above,
2. The second line contains the question.
3. The third and subsequent lines contain suggested answers.

```
X110
Jakieś pytanie?
Pierwsza odpowiedź
Druga odpowiedź
Trzecia odpowiedź
```

### Insertion tasks

1. The first line contains:
    - the letter ‘Y’, which indicates the type of question,
    - number corresponding to the positions of items to be filled in,
    - numbers corresponding to the options for the following positions,
2. The second line contains the question.
3. The third and subsequent lines contain options for filling in further gaps.

> [!NOTE]
> The number of items given in the first line of the question is not used by the programme, but if there is no character corresponding to this item, the programme will not read this line correctly. 

```
Y321
Jakiś tekst {pozycja 1}, jeszcze więcej tekstu {pozycja 2}.
Pierwsza opcja::Druga opcja::
Inna opcja::Jeszcze inna opcja::
```
