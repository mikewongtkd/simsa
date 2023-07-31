# Data Model

## Examination

- has many Examinees
- has many Groups
- might have a Schedule
- has many Officials
- has many Examiners

## Schedule

- belongs to an Examination

## Official

- belongs to an Examination
- is a (has one) User

## Panel

- belongs to an Examination
- has many Examiners
- many to many Examiners
- has many Groups

### Additional Fields
- history: denotes when Examiners join or leave and when Groups are assigned or removed

## Examiner

- belongs to an Examination
- has many Panels
- many to many Panels
- is a (has one) User
- has many Scores

## User

- belongs to a Login
- might be (have) an Official
- might be (have) an Examiner
- might be (have) an Examinee

## Login

- has many Users

## Group

- belongs to an Examination
- belongs to a Group
- has many Groups
- has many Examinees

## Score

- belongs to an Examiner
- belongs to an Examinee

## Examinee

- belongs to an Examination
- belongs to a Group
- has many Scores
- is a (has one) User
