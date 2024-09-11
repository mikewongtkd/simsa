# Data Model

## Core Classes

### Root
- has many Users

### Exam

- has many Groups
- has many Panels
- might have a Schedule
- has many Officials
- has many Technicians
- has many Examiners
- has many Examinees

### Schedule

- belongs to an Exam
- has many TimeBlocks

### TimeBlock

- has a planned-start, planned-stop, start, stop
- has many groups
- A group cannot have concurrent timeBlocks (scheduling conflict)

### User

- belongs to a Login

### Login

- has many Users

### Group

- belongs to an Exam
- belongs to a Group
- has many Groups
- has many Examinees

### Panel
Analogous to a Taekwondo tournament ring

- belongs to an Exam
- has many Examiners
- has many ComputerOperators

### Score

- belongs to an Examiner
- belongs to an Examinee

### Participant

- belongs to an Exam

#### Examinee

- belongs to a Group
- has many Scores
- is a (has one) User

#### Examiner

- belongs to a Group
- is a (has one) User
- has many Scores
