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

| Class          | Post             | Get/List | Patch/Delete     |
|----------------|------------------|----------|------------------|
| PromotionTest  | Ad               | Public   | Ad 1             |
| Court          | Ad 1, CO 2       | Public   | Ad 1, CO 2       |
| PromotionGroup | Ad 1, CO 2       | Public   | Ad 1, CO 2       |
| Examiner       | Ad 1, CO 3       | Public   | Ad 1, CO 3       |
| Examinee       | Ad 1, CO 3       | Public   | Ad 1, CO 3       |
| Score          | Ad 1, CO 4, Ex 4 | Public   | Ad 1, CO 4, Ex 4 |

**Ad:** Administrator, **CO:** Computer Operator, **Ex:** Examiner

1. Poster
2. Assigned to the court
3. Assigned to the court, and for an object assigned to the Staging court
4. Assigned to the court, and for an Examinee assigned to the court
