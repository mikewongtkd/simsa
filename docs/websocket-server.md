# WebSocket Server

## Protocol

### Data model

![Data Model](data-model.png)

### Actions

| Action | Description          |
| ------ | -------------------- |
| Post   | Create a new object  |
| Get    | Retrieve an object   |
| List   | Retrieve all objects |
| Patch  | Update an object     |
| Delete | Delete an object     |

### Permissions

| Class          | Post                      | Get/List | Patch/Delete              |
|----------------|---------------------------|----------|---------------------------|
| PromotionTest  | Admin                     | Public   | Admin^1                   |
| Court          | Admin^1, CO^2             | Public   | Admin^1, CO^2             |
| PromotionGroup | Admin^1, CO^2             | Public   | Admin^1, CO^2             |
| Examiner       | Admin^1, CO^3             | Public   | Admin^1, CO^3             |
| Examinee       | Admin^1, CO^3             | Public   | Admin^1, CO^3             |
| Score          | Admin^1, CO^4, Examiner^4 | Public   | Admin^1, CO^4, Examiner^4 |

1. Poster
2. Assigned to the court
3. Assigned to the court, and for an object assigned to the Staging court
4. Assigned to the court, and for an Examinee assigned to the court
