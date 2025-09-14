# TBBlogTest.class.st

## Review

## 1. Summary

- **Purpose**: The `TBBlogTest` class verifies the behavior of the `TBBlog` model in a TinyBlog system.  
- **Key components**:
  - **`TBBlog`** – the central blog manager that stores and retrieves posts.  
  - **`TBPost`** – represents individual blog posts, including title, text, category, and visibility.  
  - **`VORepository` / `VOMemoryRepository`** – the persistence layer used by the tests (in‑memory repository for isolation).  
- **Design patterns / frameworks**:  
  - Test-driven design using **Pharo’s `TestCase`** framework.  
  - Repository pattern via `VORepository` (a wrapper over different persistence strategies).  
  - Domain‑model encapsulation: `TBBlog` provides a façade over the collection of `TBPost` objects.

The tests exercise CRUD operations, filtering by category and visibility, and ensure that the internal bookkeeping (size, removal) behaves as expected.

---

## 2. Detailed Description

### Setup & Teardown
- **`setUp`**  
  - Stores the current repository in `previousRepository`.  
  - Switches to a fresh `VOMemoryRepository` so that each test starts with a clean, transient store.  
  - Obtains the singleton `TBBlog` via `TBBlog current` and clears any pre‑existing posts.  
  - Creates two sample posts:  
    - `first` (visible by default).  
    - `post` (explicitly marked `beVisible`).  
  - Writes `first` to the blog; `post` remains unsaved until a specific test writes it.

- **`tearDown`**  
  - Restores the original repository, ensuring no side‑effects leak into other tests.

### Test Flow
Each test follows the Arrange‑Act‑Assert pattern:

1. **Arrange** – set up any additional posts or state needed.
2. **Act** – invoke a method on `blog` (e.g., `writeBlogPost:`, `removeBlogPost:`, `allBlogPosts`, etc.).
3. **Assert** – verify the state of the blog or returned collections.

The tests cover:
- Adding posts (`testAddBlogPost`).
- Retrieving all posts, by category, or by visibility.
- Removing posts individually or en‑mass.
- Counting posts (`testSize`).
- Handling unclassified posts (`testUnclassifiedBlogPosts`).

The architecture is simple: `TBBlog` holds a collection of `TBPost` instances and offers query helpers. The repository abstraction allows swapping persistence strategies without changing the tests.

---

## 3. Functions/Methods

| Method | Purpose | Parameters | Returns | Side Effects |
|--------|---------|------------|---------|--------------|
| `setUp` | Prepares test environment. | – | – | Sets repository, clears blog, creates sample posts. |
| `tearDown` | Restores original environment. | – | – | Resets repository. |
| `testAddBlogPost` | Verify adding a post increases size. | – | – | Calls `writeBlogPost:`. |
| `testAllBlogPosts` | Verify total post count after addition. | – | – | Calls `allBlogPosts`. |
| `testAllBlogPostsFromCategory` | Verify filtering by category. | – | – | Calls `allBlogPostsFromCategory:`. |
| `testAllCategories` | Verify category listing. | – | – | Calls `allCategories`. |
| `testAllVisibleBlogPosts` | Verify visibility filtering. | – | – | Calls `allVisibleBlogPosts`. |
| `testAllVisibleBlogPostsFromCategory` | Verify visibility + category filter. | – | – | Calls `allVisibleBlogPostsFromCategory:`. |
| `testRemoveAllBlogPosts` | Verify bulk removal. | – | – | Calls `removeAllPosts`. |
| `testRemoveBlogPost` | Verify single post removal. | – | – | Calls `removeBlogPost:`. |
| `testSize` | Verify blog size after initial setup. | – | – | Calls `size`. |
| `testUnclassifiedBlogPosts` | Verify no unclassified posts in initial state. | – | – | Calls `allBlogPosts select:`. |

**Reusable utilities**  
All test methods are straightforward; no helper methods were defined, but the code could benefit from a private helper to create a post given a title and category.

---

## 4. Dependencies

| Dependency | Type | Notes |
|------------|------|-------|
| `TestCase` (Pharo) | Core library | Provides `setUp`, `tearDown`, `assert:` etc. |
| `VORepository` / `VOMemoryRepository` | External repository library (likely part of VOMemoryRepository package) | Handles persistence. The tests rely on this abstraction. |
| `TBBlog`, `TBPost` | Domain classes (TinyBlog) | Implemented elsewhere in the project. |
| `category : #'TinyBlog-Tests'` | Project classification | No external impact. |

All dependencies are standard for a Pharo test suite; no other third‑party libraries are used.

---

## 5. Additional Notes

### Strengths
- **Isolation**: Using an in‑memory repository guarantees no interference between tests or with production data.  
- **Clear intent**: Each test method names the behavior it validates, making the suite self‑documenting.  
- **Coverage**: The tests hit all public query and mutation methods of `TBBlog`.

### Potential Improvements
1. **Setup Refactoring**  
   - Extract post creation into a helper method (`createPostWithTitle:text:category:visible:`) to reduce duplication.  
   - Consider moving common initialization (e.g., clearing the blog) into a `commonSetUp` method that can be reused if more tests are added.

2. **Edge‑Case Testing**  
   - Verify behavior when adding a `nil` post or a post with an empty title/category.  
   - Test removal of a post that does not exist or has already been removed.  
   - Test ordering of posts (e.g., newest first) if such logic exists.

3. **Repository Robustness**  
   - Add a test that writes posts, then re‑instantiates the `TBBlog` (or re‑calls `TBBlog current`) to ensure persistence is correctly handled.  
   - Test switching repositories mid‑test to confirm that the system does not silently use the wrong repository.

4. **Visibility Handling**  
   - Currently only one post is explicitly made visible. It might be beneficial to test posts that are explicitly hidden to ensure `allVisibleBlogPosts` behaves correctly.

5. **Use of `anyOne`**  
   - `testRemoveBlogPost` uses `anyOne` to pick a post. This is fine for a small set but can lead to nondeterministic behavior if the collection grows. A more deterministic selection (e.g., the first post) would make the test more robust.

6. **Documentation**  
   - Adding a brief comment before each test explaining the scenario being tested would aid maintainability.

### Future Enhancements
- **Parameterize tests**: Use `DataDrivenTestCase` to feed different categories/visibility states.  
- **Performance testing**: Add a test that writes a large number of posts to evaluate scalability.  
- **Integration tests**: Hook the tests into the GUI layer (if any) to ensure the UI reflects changes.

Overall, the test suite is well‑structured and fulfills its purpose of validating core blog functionality. The suggested improvements mainly aim at increasing robustness and maintainability as the project evolves.

## Code Critique



## Code Preview

```smalltalk
Class {
	#name : #TBBlogTest,
	#superclass : #TestCase,
	#instVars : [
		'blog',
		'post',
		'first',
		'previousRepository'
	],
	#category : #'TinyBlog-Tests'
}

{ #category : #setup }
TBBlogTest >> setUp [
	previousRepository := VORepository current.
   VORepository setRepository: VOMemoryRepository new.

	blog := TBBlog current.
	blog removeAllPosts.
	
	first := (TBPost title: 'A title' text: 'A text' category: 'First Category').
	blog writeBlogPost: first.
	
 	post := (TBPost title: 'Another title' text: 'Another text' category: 'Second Category') beVisible
]

{ #category : #setup }
TBBlogTest >> tearDown [
	VORepository setRepository: previousRepository
]

{ #category : #tests }
TBBlogTest >> testAddBlogPost [
	blog writeBlogPost: post.
	self assert: blog size equals: 2
]

{ #category : #tests }
TBBlogTest >> testAllBlogPosts [
   blog writeBlogPost: post.
   self assert: blog allBlogPosts size equals: 2.
]

{ #category : #tests }
TBBlogTest >> testAllBlogPostsFromCategory [
   self assert: (blog allBlogPostsFromCategory: 'First Category') size equals: 1
]

{ #category : #tests }
TBBlogTest >> testAllCategories [
   blog writeBlogPost: post.
   self assert: (blog allCategories) size equals: 2.
]

{ #category : #tests }
TBBlogTest >> testAllVisibleBlogPosts [
   blog writeBlogPost: post.
   self assert: blog allVisibleBlogPosts size equals: 1.
]

{ #category : #tests }
TBBlogTest >> testAllVisibleBlogPostsFromCategory [
   blog writeBlogPost: post.
   self 
		assert: (blog allVisibleBlogPostsFromCategory: 'First Category') size 
		equals: 0.
   self 
		assert: (blog allVisibleBlogPostsFromCategory: 'Second Category') size 
		equals: 1.
]

{ #category : #tests }
TBBlogTest >> testRemoveAllBlogPosts [
   blog removeAllPosts.
   self assert: blog size equals: 0.
]

{ #category : #tests }
TBBlogTest >> testRemoveBlogPost [
    self assert: blog size equals: 1.
    blog removeBlogPost: blog allBlogPosts anyOne.
    self assert: blog size equals: 0
]

{ #category : #tests }
TBBlogTest >> testSize [
   self assert: blog size equals: 1
]

{ #category : #tests }
TBBlogTest >> testUnclassifiedBlogPosts [
   self assert: (blog allBlogPosts select: [ :p | p isUnclassified ]) size equals: 0.
]



```
