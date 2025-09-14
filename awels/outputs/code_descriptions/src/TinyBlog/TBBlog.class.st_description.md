# TBBlog.class.st

## Review

## 1. Summary

**Purpose & Functionality**  
`TBBlog` is a tiny, self‑contained blog engine. It stores blog posts (`TBPost`) and an administrator (`TBAdministrator`) and persists itself as a singleton document in a Voyage‑backed database (either an in‑memory store or a MongoDB instance).  
The class offers CRUD‑like operations for blog posts, quick accessors for categories and visibility, and helper methods to initialise the demo data or reset the database.

**Key Components**  
| Component | Role |
|-----------|------|
| `posts` (OrderedCollection) | In‑memory cache of `TBPost` objects belonging to the blog. |
| `adminUser` (`TBAdministrator`) | Holds the default admin account. |
| `uniqueInstance` (class variable) | Intended to enforce a singleton but unused. |
| Voyage repository (`VOMemoryRepository`, `VOMongoRepository`) | Persist the singleton `TBBlog` document. |
| `TBBlog createDemoPosts` | Seed the database with sample posts. |

**Design Patterns & Libraries**  
* **Singleton** – `TBBlog` is intended to be a singleton per Voyage repository.  
* **Active Record** – The object persists itself (`#save`) and relies on Voyage for CRUD.  
* **Factory** – `#createAdministrator` builds the admin user from default credentials.  
* **Voyage** – Lightweight NoSQL persistence layer used for both memory and Mongo backends.  

---

## 2. Detailed Description

### 2.1 Core Flow

| Stage | Action |
|-------|--------|
| **Startup** | `TBBlog initialize` (class side) calls `#reset`, which invokes `initializeVoyageOnMemoryDB`. This makes Voyage create an in‑memory repository and enable singleton mode for *all* Voyage entities. |
| **Current Instance** | `TBBlog current` queries the repository (`#selectAll`). If an instance exists it returns the first; otherwise it creates a new instance (`self new`) and persists it (`#save`). |
| **Adding Posts** | `writeBlogPost:` appends the `TBPost` to the local `posts` collection and calls `#save` to persist the whole `TBBlog` document. |
| **Removing Posts** | `removeBlogPost:` or `removeAllPosts:` modify `posts` then `#save`. |
| **Retrieval** | Various `#all…` methods filter `posts` by visibility or category. They operate on the in‑memory collection, so no additional DB queries are required. |
| **Demo Data** | `createDemoPosts` invokes `writeBlogPost:` repeatedly, producing five sample posts. |

### 2.2 Assumptions & Constraints

* **Single Instance** – The code expects only one `TBBlog` document per repository. The class variable `uniqueInstance` is declared but never used; the actual singleton enforcement relies solely on Voyage’s `enableSingleton`.
* **No Concurrency** – Operations are synchronous and thread‑unsafe. In a multi‑threaded environment this could lead to lost updates.
* **No Validation** – Posts are added without checks for duplicates, missing fields, or bad data. Admin credentials are hard‑coded and not hashed.
* **No Pagination or Sorting** – All posts are loaded into memory; heavy datasets would strain memory.
* **Voyage‑only** – The class depends on Voyage for persistence; replacing the backend would require rewriting the persistence logic.

### 2.3 Architecture & Design Choices

* **Single Document** – The entire blog (posts + admin) is stored as one document. This simplifies access but may become unwieldy with many posts. A more scalable design would shard posts into separate documents or collections.
* **In‑Memory Collection** – Using an `OrderedCollection` keeps the order of insertion, which is handy for displaying the newest first but is not persisted independently.
* **Voyage Root** – Declaring `isVoyageRoot` enables the class to be stored as a top‑level document without further annotations.

---

## 3. Functions/Methods

| Method | Purpose | Inputs | Outputs | Side Effects |
|--------|---------|--------|---------|--------------|
| `current` (class) | Return the singleton `TBBlog` instance | none | `TBBlog` instance | May create & persist a new instance |
| `defaultAdminLogin` / `defaultAdminPassword` | Default admin credentials | none | `String` | none |
| `reset` (class) | Reset the database to a fresh in‑memory state | none | none | Reinitialises the Voyage memory repository |
| `createAdministrator` (instance) | Builds an admin user from defaults | none | `TBAdministrator` | none |
| `initialize` (instance) | Initialise collections & admin | none | none | Sets `posts`, `adminUser` |
| `writeBlogPost:` | Persist a new post | `TBPost` | none | Adds to `posts`, saves document |
| `removeBlogPost:` | Delete a post | `TBPost` | none | Removes from `posts`, saves document |
| `removeAllPosts:` | Clear all posts | none | none | Resets `posts`, saves document |
| `allBlogPosts` | Retrieve all posts | none | `OrderedCollection` | none |
| `allBlogPostsFromCategory:` | Filter by category | `String` | `OrderedCollection` | none |
| `allCategories` | List distinct categories | none | `Set` | none |
| `allVisibleBlogPosts` / `allVisibleBlogPostsFromCategory:` | Filter by visibility | optional `String` | `OrderedCollection` | none |
| `size` | Number of posts | none | `Integer` | none |
| `administrator` | Get the admin user | none | `TBAdministrator` | none |

*Utility Methods*  
`#createDemoPosts` (class) seeds the database with hard‑coded sample posts.  
`#initializeVoyageOnMemoryDB` / `#initializeVoyageOnLocalhostMongoDB` configure the repository.

---

## 4. Dependencies

| Dependency | Type | Notes |
|------------|------|-------|
| **Voyage** (`VOMemoryRepository`, `VOMongoRepository`) | Third‑party | Handles persistence, singleton mode, and basic CRUD. |
| **TBPost** | Third‑party / internal | Represents individual posts. Must implement `#category`, `#isVisible`. |
| **TBAdministrator** | Third‑party / internal | Represents the admin account. |
| **Pharo VM** | Platform | Assumes the code runs on a Pharo environment. |
| **Collections** (`OrderedCollection`, `Set`) | Standard | Built‑in Smalltalk collections. |

The code assumes Voyage is loaded and configured. If Voyage is absent, the repository calls will fail.

---

## 5. Additional Notes

### 5.1 Edge Cases & Limitations

* **Duplicate Posts** – No deduplication; two identical posts can coexist.  
* **Missing Category** – `allCategories` will include `nil` if a post has no category.  
* **Visibility Toggle** – There is no explicit method to toggle a post’s visibility.  
* **Concurrency** – Simultaneous writers could corrupt `posts`.  
* **Large Datasets** – All posts are kept in memory; scaling beyond a few thousand posts will impact performance.  
* **Security** – Admin credentials are plain text; no password hashing.  

### 5.2 Potential Enhancements

| Area | Suggested Improvement |
|------|------------------------|
| **Persistence** | Store each post as its own document or use a collection, enabling index‑based queries. |
| **Validation** | Add validation logic in `writeBlogPost:` (e.g., non‑empty title, unique slug). |
| **Indexing** | Maintain a hash/dictionary of posts by category for O(1) retrieval. |
| **Pagination** | Implement `#postsFromPage:pageSize:` or similar to avoid loading all posts. |
| **Admin Security** | Store hashed passwords, support password rotation, and enforce role‑based access. |
| **Event Logging** | Emit events on create/remove for analytics or audit trails. |
| **API** | Expose a small RESTful interface (via GsWebService or Smalltalk HTTP) for external consumption. |
| **Testing** | Unit tests for each method, especially boundary cases (empty repository, invalid inputs). |
| **Error Handling** | Wrap `#save` calls in `try/catch` to gracefully handle repository failures. |
| **Singleton Enforcement** | Use the class variable `uniqueInstance` or a proper singleton pattern instead of relying solely on Voyage. |
| **Configuration** | Allow the repository type to be chosen via configuration instead of hard‑coded reset. |

### 5.3 Observations

* The `uniqueInstance` class variable is unused; if you intend to enforce the singleton in the code itself, you should implement a getter that caches the instance or rely on Voyage’s singleton mechanism entirely.  
* The `#reset` method always switches to an in‑memory repository, discarding any persisted data. For a production system you’d want separate “development” and “production” repositories.  
* The `#initializeVoyageOnLocalhostMongoDB` helper is never invoked; consider adding a `#useMongo` method or a configuration flag.  

Overall, the code is concise, easy to read, and demonstrates a straightforward use of Voyage for persistence. With the above enhancements, it could evolve into a more robust, scalable blogging backend.

## Code Critique



## Code Preview

```smalltalk
"
a TBBlog represents a blog that contains posts.

TBBlog is a Voyage root.
The singleton blog object is stored in a Voyage repository that can be attached to a memory or a Mongo backend.

How to reset the database:

	TBBlog reset.
	TBBlog createDemoPosts
"
Class {
	#name : #TBBlog,
	#superclass : #Object,
	#instVars : [
		'posts',
		'adminUser'
	],
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'TinyBlog-Model'
}

{ #category : #'data sample' }
TBBlog class >> createDemoPosts [
   "TBBlog createDemoPosts"
   self current 
      writeBlogPost: ((TBPost title: 'Welcome in TinyBlog' text: 'TinyBlog is a small blog engine made with Pharo.' category: 'TinyBlog') visible: true);
      writeBlogPost: ((TBPost title: 'Report Pharo Sprint' text: 'Friday, June 12 there was a Pharo sprint / Moose dojo. It was a nice event with more than 15 motivated sprinters. With the help of candies, cakes and chocolate, huge work has been done' category: 'Pharo') visible: true);
      writeBlogPost: ((TBPost title: 'Brick on top of Bloc - Preview' text: 'We are happy to announce the first preview version of Brick, a new widget set created from scratch on top of Bloc. Brick is being developed primarily by Alex Syrel (together with Alain Plantec, Andrei Chis and myself), and the work is sponsored by ESUG. 
      Brick is part of the Glamorous Toolkit effort and will provide the basis for the new versions of the development tools.' category: 'Pharo') visible: true);
      writeBlogPost: ((TBPost title: 'The sad story of unclassified blog posts' text: 'So sad that I can read this.') visible: true);
      writeBlogPost: ((TBPost title: 'Working with Pharo on the Raspberry Pi' text: 'Hardware is getting cheaper and many new small devices like the famous Raspberry Pi provide new computation power that was one once only available on regular desktop computers.' category: 'Pharo') visible: true)
]

{ #category : #accessing }
TBBlog class >> current [
	^ self selectAll
		ifNotEmpty: [ :x | x anyOne ]
		ifEmpty: [ self new save ]
]

{ #category : #'default values' }
TBBlog class >> defaultAdminLogin [
   ^ 'admin'
]

{ #category : #'default values' }
TBBlog class >> defaultAdminPassword [
   ^ 'topsecret'
]

{ #category : #'class initialization' }
TBBlog class >> initialize [ 
	self reset
]

{ #category : #voyage }
TBBlog class >> initializeLocalhostMongoDB [
   | repository |
   repository := VOMongoRepository database: 'tinyblog'.
   repository enableSingleton.
]

{ #category : #voyage }
TBBlog class >> initializeVoyageOnMemoryDB [
   VOMemoryRepository new enableSingleton
]

{ #category : #voyage }
TBBlog class >> isVoyageRoot [
   "Indicates that instances of this class are top level documents
    in noSQL databases"
   ^ true
]

{ #category : #accessing }
TBBlog class >> reset [
	self initializeVoyageOnMemoryDB
]

{ #category : #accessing }
TBBlog >> administrator [
   ^ adminUser
]

{ #category : #accessing }
TBBlog >> allBlogPosts [
   ^ posts
]

{ #category : #accessing }
TBBlog >> allBlogPostsFromCategory: aCategory [
   ^ self allBlogPosts select: [ :p | p category = aCategory ]
]

{ #category : #accessing }
TBBlog >> allCategories [
   ^(self allBlogPosts collect: [ :p | p category ]) asSet
]

{ #category : #accessing }
TBBlog >> allVisibleBlogPosts [
   ^ self allBlogPosts select: [ :p | p isVisible ]
]

{ #category : #accessing }
TBBlog >> allVisibleBlogPostsFromCategory: aCategory [
   ^ self allBlogPosts select: [ :p | p category = aCategory and: [ p isVisible ] ]
]

{ #category : #initialization }
TBBlog >> createAdministrator [
   ^ TBAdministrator login: self class defaultAdminLogin password: self class defaultAdminPassword

]

{ #category : #initialization }
TBBlog >> initialize [
   super initialize.
   posts := OrderedCollection new.
   adminUser := self createAdministrator
]

{ #category : #operations }
TBBlog >> removeAllPosts [
	posts := OrderedCollection new.
	self save.
]

{ #category : #operations }
TBBlog >> removeBlogPost: aPost [
    posts remove: aPost ifAbsent: [ ].
    self save.
]

{ #category : #accessing }
TBBlog >> size [
	 ^ posts size
]

{ #category : #operations }
TBBlog >> writeBlogPost: aPost [
	"Write the blog post in database"
	posts add: aPost.
	self save
]



```
