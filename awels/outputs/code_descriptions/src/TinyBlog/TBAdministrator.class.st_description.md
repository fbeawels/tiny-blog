# TBAdministrator.class.st

## Review

## 1. Summary
- **Purpose** – The `TBAdministrator` class models an administrative user in a TinyBlog system. It stores a login name and a password (hashed with MD5) and exposes simple getters/setters.
- **Key Components**
  - Instance variables: `login`, `password`.
  - Class‑side constructor `login:password:` for convenient object creation.
  - Instance accessors for `login` and `password` (with password setter performing hashing).
- **Design Patterns / Libraries**
  - No explicit design pattern; the class is a plain data holder.
  - Uses the Smalltalk `MD5` class (from the standard Crypto library) to hash passwords.

## 2. Detailed Description
- **Creation Flow**  
  1. Call the class method `login:password:`.  
  2. It creates a new instance (`self new`), sets the `login` and `password` via the instance setters, and returns the object with `yourself`.

- **Runtime Behavior**  
  - The `login` accessor simply returns the stored username.  
  - The `password` setter accepts a plain text password, hashes it using `MD5 hashMessage:`, and stores the hash.  
  - The `password` accessor returns the stored hash, not the original password (good for security).

- **Assumptions & Constraints**  
  - The class assumes that the `MD5` hash algorithm is available and that the application treats the stored hash as sufficient for authentication.  
  - No validation of `login` or `password` format, length, or uniqueness is performed here; such logic would need to live elsewhere (e.g., a service or validator).  
  - The class does not provide any methods for authentication or session handling; it only represents data.

- **Architecture**  
  - The model is intentionally minimalistic; business logic (authentication, permission checks, post editing) is expected to be handled by higher‑level services or controllers.  
  - The use of a factory method (`login:password:`) is a convenience to avoid calling `new` and then setting fields separately.

## 3. Functions/Methods

| Method | Purpose | Inputs | Outputs | Side Effects |
|--------|---------|--------|---------|--------------|
| `TBAdministrator class >> login:login password:password` | Factory constructor. Creates a new `TBAdministrator` with provided credentials. | `login` (String), `password` (String) | A fully initialized `TBAdministrator` instance | None |
| `TBAdministrator >> login` | Returns the username. | None | `String` | None |
| `TBAdministrator >> login:` | Sets the username. | `anObject` (String) | `nil` (implicitly, method returns the value of `anObject`) | Modifies `login` ivar |
| `TBAdministrator >> password` | Returns the stored password hash. | None | `String` | None |
| `TBAdministrator >> password:` | Stores the password hash. | `anObject` (String, plain text) | `nil` | Computes MD5 hash and assigns to `password` ivar |

- **Reusable/Utility**  
  - The password setter’s MD5 hashing is a small utility. If multiple classes need password hashing, it might be worth moving the hashing logic into a dedicated utility or a mixin for reuse.

## 4. Dependencies
| Dependency | Type | Notes |
|------------|------|-------|
| `MD5` | Standard (Crypto) | Part of the Smalltalk Crypto package. Provides `hashMessage:` method. |
| `Object` | Standard | Base class. |
| None else | | |

- **Platform Specifics** – No platform‑specific code; however, availability of the `MD5` class depends on the Crypto library being loaded.

## 5. Additional Notes
### Edge Cases / Limitations
- **Security** – MD5 is considered cryptographically weak for password storage. A modern implementation should use a stronger algorithm (e.g., SHA‑256 with salt or a dedicated password hashing scheme like PBKDF2, bcrypt, scrypt, or Argon2).
- **Password Retrieval** – The `password` accessor returns the hash, not the plaintext, which is appropriate. However, if the rest of the system expects the raw hash to be the same as the stored value, it is fine; otherwise, consider naming the accessor `passwordHash` for clarity.
- **No Validation** – There is no validation on the `login` or `password` values; null/empty strings or invalid characters could slip through.
- **No Persistence** – The class does not handle persistence; integration with a database or file system must be done elsewhere.
- **Immutability** – Passwords can be changed after creation; if immutability is desired, consider making the ivars private and providing a `withPassword:` method that returns a new instance.

### Potential Enhancements
1. **Use Stronger Password Hashing** – Replace MD5 with a stronger algorithm, incorporate salting, and store the salt alongside the hash.
2. **Encapsulate Password Handling** – Introduce a `TBPassword` value object that encapsulates hashing logic, making the `TBAdministrator` class cleaner.
3. **Add Validation** – Validate that login is non‑empty and conforms to expected patterns; enforce password strength policies.
4. **Authentication Method** – Add an `authenticate:` method that accepts a candidate password and returns a boolean by comparing hashes.
5. **Role/Permission System** – If multiple roles exist, a role attribute could be added to the class.
6. **Persistence Interface** – Add methods for serializing/deserializing or integrate with an ORM.

Overall, the class is a straightforward data holder, suitable as a starting point, but would benefit from stronger security practices and additional business logic encapsulation.

## Code Critique



## Code Preview

```smalltalk
"
I represent an Administrator of a blog.
I can access admin parts of the application and edit posts.
"
Class {
	#name : #TBAdministrator,
	#superclass : #Object,
	#instVars : [
		'login',
		'password'
	],
	#category : #'TinyBlog-Model'
}

{ #category : #'instance creation' }
TBAdministrator class >> login: login password: password [
  ^ self new
    login: login;
    password: password;
    yourself
]

{ #category : #accessing }
TBAdministrator >> login [
	^ login
]

{ #category : #accessing }
TBAdministrator >> login: anObject [
	login := anObject
]

{ #category : #accessing }
TBAdministrator >> password [
	^ password
]

{ #category : #accessing }
TBAdministrator >> password: anObject [
	password := (MD5 hashMessage: anObject)
]



```
