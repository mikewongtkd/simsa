# Data Model

## Core Classes

### Exam

- has many Groups
- might have a Schedule
- has many Officials
- has many Examiners
- has many Examinees

### Schedule

- belongs to an Exam
- has many TimeBlocks

### TimeBlock

- has a planned-start, planned-stop, start, stop
- has many groups
- A group cannot have concurrent timeblocks (scheduling conflict)

### User

- belongs to a Login

### Login

- has many Users

### Group

- label

- belongs to an Examination
- belongs to a Group
- has many Groups
- has many Examinees or Examiners

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

#### Official 

- is a (has one) User

