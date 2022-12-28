# Data Model

## Examination

- has many Examinees
- has many Cohorts
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
- has many Cohorts

## PanelExaminer

- belongs to a Panel
- belongs to an Examiner

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

## Cohort

- belongs to an Examination
- belongs to a Cohort
- has many Cohorts
- has many Examinees

## Score

- belongs to an Examiner
- belongs to an Examinee

## Examinee

- belongs to an Examination
- belongs to a Cohort
- has many Scores
- is a (has one) User
