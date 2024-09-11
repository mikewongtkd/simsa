# WebSocket Server

## Security Policy

### Data model

![Data Model](data-model.png)

### Actions

| Action | Description                 |
| ------ | --------------------------- |
| Post   | Create/Update a new object  |
| Get    | Retrieve an object          |
| Delete | Delete an object            |

### Roles

- Root
- Technician
- ComputerOperator
- Examiner
- Official
- Public

Root > Technician > ComputerOperator > Examiner > Examinee > Official > Public

#### Root 

*Root* has complete access to the entire system and is a special label in the user data.

#### Official

*Official* has read-only access to an Exam. This is for VIPs and
decision-makers to get the latest information and then direct
administrators to enact decisions.

#### Technician

*Technicians* have read/write access to an Exam. Technicians are able to
execute on policy decisions made by Officials. The lead 

#### ComputerOperator

*ComputerOperator* has read-only access to an Exam, as well as write access to
Groups and Exam Scores within their panel. Computer Operators are similar to
Technicians but require less training and therefore their scope is reduced to
just their testing panel. 

A technican can train a volunteer to be a computer operator in a half-hour as a
system non-functional requirement.

#### Examiner

*Examiner* has read-only access to an Exam, and write access to the Exam Scores.

#### Examinee

*Examinee* has read-only access to the Exam's general information, Schedule,
and their own exam progress. Examinee has write access to their user
information and login information.

#### Public

*Public* has read-only access to any Exam's general information and Schedule.

## Protocol
