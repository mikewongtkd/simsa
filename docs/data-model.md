# Data Model

## Core Classes

### Exam

- has many Examinees
- has many Groups
- might have a Schedule
- has many Officials
- has many Examiners

### Schedule

- belongs to an Examination

### User

- belongs to a Login

### Login

- has many Users

### Group

- belongs to an Examination
- belongs to a Group
- has many Groups
- has many Examinees

## Panel

- belongs to an Examination
- has many Examiners

### Score

- belongs to an Examiner
- belongs to an Examinee

### Role

## Roles

### Examinee

- belongs to an Examination
- belongs to a Group
- has many Scores
- is a (has one) User

### Examiner

- belongs to an Examination
- has many Panels
- is a (has one) User
- has many Scores

### Official 

- belongs to an Examination
- is a (has one) User

