# TBPostsListComponent.class.st

## Review

## 1. Summary  
**Purpose** – `TBPostsListComponent` is a UI component that displays a list of blog posts. It is responsible for:

* Rendering the category sidebar (via `TBCategoriesComponent`).  
* Rendering the list of posts (via `TBPostComponent` for each post).  
* Showing an optional login‑error alert when an admin login attempt fails.  
* Navigating to the administration view when an admin logs in successfully.

**Key components**

| Component | Responsibility |
|-----------|----------------|
| `TBPostsListComponent` | Parent UI component that coordinates the rendering of categories, posts, and login error messages. |
| `TBCategoriesComponent` | Renders the list of blog categories and informs the parent when a category is selected. |
| `TBPostComponent` | Renders the details of a single post. |
| `TBAdminComponent` | The administrative screen shown after a successful login. |

**Notable patterns / libraries**

* Smalltalk / Pharo class hierarchy.  
* Bootstrap‑like rendering helpers (`tbsContainer`, `tbsRow`, `tbsColumn`, `tbsAlert`).  
* Simple MD5 hash comparison for password validation.  
* MVC‑ish separation: the component delegates rendering to sub‑components, and actions are triggered via callbacks.

---

## 2. Detailed Description  

### Core Flow

1. **Initialization** – The component is instantiated with two instance variables:  
   * `currentCategory` – the category filter (default `nil`, meaning “All”).  
   * `showLoginError` – a flag that indicates whether a login error should be displayed.

2. **Rendering** – `renderContentOn:` is overridden to lay out a two‑column Bootstrap container:  
   * The first column calls `renderCategoryColumnOn:` which simply delegates to `basicRenderCategoriesOn:` → `categoriesComponent`.  
   * The second column calls `renderPostColumnOn:` which first checks `showLoginError` (and clears it) then renders the posts list via `basicRenderPostsOn:` → `postComponentFor:`.  

3. **Post Selection** – `readSelectedPosts` pulls posts from the underlying blog model.  
   * If no category or “All” is selected, it fetches all visible posts.  
   * Otherwise, it filters by the chosen category.

4. **Login Flow** – When the user attempts to log in, `tryConnectionWithLogin:andPassword:` is invoked (presumably from a login form).  
   * It compares the supplied credentials against the blog’s administrator credentials (after MD5 hashing the password).  
   * On success it stores the admin in the current session and calls `goToAdministrationView`.  
   * On failure it sets `showLoginError` so that the next render will show an alert.

5. **Navigation** – `goToAdministrationView` simply calls `self call: TBAdminComponent new`, which is a Pharo idiom for switching the current component.

### Dependencies & Assumptions

* The component expects a `blog` object with methods `allCategories`, `allVisibleBlogPosts`, `allVisibleBlogPostsFromCategory:`, and `administrator`.  
* It relies on a `session` object that exposes a writable `currentAdmin` slot.  
* Bootstrap helpers (`tbsContainer`, `tbsRow`, `tbsColumn`, `tbsAlert`) are part of the UI framework in use (likely a Pharo Bootstrap wrapper).  
* MD5 hashing is used for password comparison; this is acceptable for demonstration but not secure for production.

---

## 3. Functions/Methods  

| Method | Purpose | Parameters | Returns | Side Effects |
|--------|---------|------------|---------|--------------|
| `basicRenderCategoriesOn:` | Renders the category sidebar | `html` | void | Calls `self categoriesComponent` |
| `basicRenderPostsOn:` | Renders each post | `html` | void | Calls `self postComponentFor:` for each post |
| `categoriesComponent` | Instantiates the categories component | None | `TBCategoriesComponent` | No state change |
| `currentCategory` | Getter | None | `Object` | None |
| `currentCategory:` | Setter | `anObject` | void | Updates `currentCategory` |
| `goToAdministrationView` | Switches to the admin screen | None | void | Calls `self call:` |
| `hasLoginError` | Checks if a login error should be shown | None | `Boolean` | None |
| `loginErrorMessage` | Returns the error message string | None | `String` | None |
| `loginErrorOccured` | Flags that a login error happened | None | void | Sets `showLoginError := true` |
| `postComponentFor:` | Builds a post component for a single post | `aPost` | `TBPostComponent` | No state change |
| `readSelectedPosts` | Returns the posts to display based on `currentCategory` | None | `Collection` | None |
| `renderCategoryColumnOn:` | Layout for the category column | `html` | void | Calls `basicRenderCategoriesOn:` |
| `renderContentOn:` | Main layout; renders categories and posts | `html` | void | Calls super & layout methods |
| `renderLoginErrorMessageIfAnyOn:` | Renders the login error alert if needed | `html` | void | Sets `showLoginError := false` |
| `renderPostColumnOn:` | Layout for the posts column | `html` | void | Calls `renderLoginErrorMessageIfAnyOn:` & `basicRenderPostsOn:` |
| `tryConnectionWithLogin:andPassword:` | Authenticates an admin user | `login`, `password` | void | Sets session, calls `goToAdministrationView` or `loginErrorOccured` |

**Reusable utilities**  
- `readSelectedPosts` can be used by other components that need the same filtered post list.  
- `postComponentFor:` is a simple factory that could be overridden for custom post rendering.

---

## 4. Dependencies  

| External | Type | Notes |
|----------|------|-------|
| `TBScreenComponent` | Base class (Pharo) | Provides generic screen behavior, probably part of the TinyBlog UI framework. |
| `TBCategoriesComponent` | UI component | Expects `categories:` and `postsList:` arguments. |
| `TBPostComponent` | UI component | Expects `post:` argument. |
| `TBAdminComponent` | UI component | The admin dashboard. |
| `MD5` | Cryptographic helper | Standard library for hashing. |
| `tbsContainer`, `tbsRow`, `tbsColumn`, `tbsAlert` | Bootstrap helpers | Likely part of a Pharo Bootstrap wrapper. |
| `self blog` | Domain model | Must expose the methods used. |
| `self session` | Session store | Must expose `currentAdmin`. |

All dependencies are either part of the TinyBlog application or the Pharo standard library. No platform‑specific APIs are used.

---

## 5. Additional Notes  

### Strengths  

* **Clear separation of concerns** – UI rendering is delegated to sub‑components, keeping the main component lightweight.  
* **Simple and readable code** – Small, single‑purpose methods make the component easy to understand.  
* **Reusability** – The `readSelectedPosts` helper could be used elsewhere.

### Potential Issues & Edge Cases  

1. **Password Security** – Using MD5 for password hashing is not secure. Consider a stronger hash (e.g., PBKDF2, bcrypt).  
2. **Category Comparison** – The string `'All'` is hard‑coded. If the “All” label ever changes or is localized, the logic will break. Use a dedicated constant or sentinel value.  
3. **Login Error Reset** – The flag `showLoginError` is cleared *after* rendering. If an error occurs but the component does not re‑render immediately (e.g., because the same view is retained), the error might disappear silently.  
4. **Session Management** – The method `tryConnectionWithLogin:andPassword:` directly mutates `self session`. It might be safer to encapsulate this logic in a dedicated authentication service.  
5. **Error Messaging** – The login error message is hard‑coded in English. For a multilingual application this would need to be externalized.  

### Future Enhancements  

* **Add unit tests** – Test the filtering logic, login handling, and rendering of components.  
* **Internationalization** – Move strings like `'Inccorect login and/or password'` and `'All'` to a message catalog.  
* **Better auth** – Replace MD5 with a secure password hashing scheme and move authentication into a service layer.  
* **Event‑driven UI updates** – Instead of relying on a flag reset after rendering, trigger a UI refresh when `loginErrorOccured` is called.  
* **Pagination / Lazy loading** – For large blogs, the `basicRenderPostsOn:` method could be adapted to render only a page of posts.  

Overall, the component is well‑structured for its intended purpose, but a few small improvements could enhance security, maintainability, and user experience.

## Code Critique



## Code Preview

```smalltalk
"
I'm responsible for displaying a list of posts. I delegare to the post component the display of a single post.
I'm in the contact with a category component. 
"
Class {
	#name : #TBPostsListComponent,
	#superclass : #TBScreenComponent,
	#instVars : [
		'currentCategory',
		'showLoginError'
	],
	#category : #'TinyBlog-Components'
}

{ #category : #rendering }
TBPostsListComponent >> basicRenderCategoriesOn: html [
	html render: self categoriesComponent
]

{ #category : #rendering }
TBPostsListComponent >> basicRenderPostsOn: html [
	self readSelectedPosts do: [ :p | 
		html render: (self postComponentFor: p) ]
]

{ #category : #'components creation' }
TBPostsListComponent >> categoriesComponent [
	^ TBCategoriesComponent
			categories: self blog allCategories
			postsList: self
]

{ #category : #accessing }
TBPostsListComponent >> currentCategory [
	^ currentCategory
]

{ #category : #accessing }
TBPostsListComponent >> currentCategory: anObject [
	currentCategory := anObject
]

{ #category : #actions }
TBPostsListComponent >> goToAdministrationView [
         self call: TBAdminComponent new
]

{ #category : #accessing }
TBPostsListComponent >> hasLoginError [
	^ showLoginError ifNil: [ false ]
]

{ #category : #accessing }
TBPostsListComponent >> loginErrorMessage [
	^ 'Inccorect login and/or password'
]

{ #category : #actions }
TBPostsListComponent >> loginErrorOccured [
        showLoginError := true
]

{ #category : #'components creation' }
TBPostsListComponent >> postComponentFor: aPost [
	^ TBPostComponent new post: aPost
]

{ #category : #accessing }
TBPostsListComponent >> readSelectedPosts [
	^ (self currentCategory isNil or: [ self currentCategory = 'All' ])
		ifTrue: [ self blog allVisibleBlogPosts ]
		ifFalse: [ self blog allVisibleBlogPostsFromCategory: self currentCategory ]
]

{ #category : #rendering }
TBPostsListComponent >> renderCategoryColumnOn: html [
   html tbsColumn
      extraSmallSize: 12;
      smallSize: 2;
      mediumSize: 4;
      with: [ self basicRenderCategoriesOn: html ]
]

{ #category : #rendering }
TBPostsListComponent >> renderContentOn: html [
	super renderContentOn: html.
	html tbsContainer: [
		html tbsRow
			showGrid;
			with: [ self renderCategoryColumnOn: html.
                  self renderPostColumnOn: html ] ]
]

{ #category : #rendering }
TBPostsListComponent >> renderLoginErrorMessageIfAnyOn: html [
	self hasLoginError ifTrue: [
		showLoginError := false.
		html tbsAlert
			beDanger ;
			with: self loginErrorMessage ]
]

{ #category : #rendering }
TBPostsListComponent >> renderPostColumnOn: html [
	html tbsColumn
		extraSmallSize: 12;
		smallSize: 10;
		mediumSize: 8;
		with: [
			self renderLoginErrorMessageIfAnyOn: html.
			self basicRenderPostsOn: html ]
]

{ #category : #callbacks }
TBPostsListComponent >> tryConnectionWithLogin: login andPassword:
    password [
   (login = self blog administrator login and: [
      (MD5 hashMessage: password) = self blog administrator password
])
ifTrue: [
            self session currentAdmin: self blog administrator.
            self goToAdministrationView ]
         ifFalse: [ self loginErrorOccured ]
]



```
