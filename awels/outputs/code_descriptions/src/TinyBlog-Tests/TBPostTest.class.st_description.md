# TBPostTest.class.st

## Review

## 1. Summary
The file `TBPostTest` is a small unit‑test suite written in Pharo’s Smalltalk dialect.  
Its sole purpose is to verify the creation logic of the `TBPost` class.  
Key components:

| Component | Role |
|-----------|------|
| `TBPostTest` | A `TestCase` subclass that contains test methods |
| `testPostIsCreatedCorrectly` | Tests that a post created with a category retains the correct title, text, and (implicitly) category |
| `testWithoutCategoryIsUnclassified` | Tests that a post created without an explicit category is marked as *unclassified* and is not visible |

The tests rely on Pharo’s built‑in `TestCase` framework, the `assert:equals:` and `deny:` assertion methods, and the public factory methods of `TBPost` (`title:text:category:` and `title:text:`).

## 2. Detailed Description
### Execution Flow
1. **Class definition** – `TBPostTest` is declared in the `TinyBlog-Tests` category and inherits from `TestCase`.
2. **Test discovery** – The Pharo test runner scans for methods whose selectors begin with `test`. It will automatically invoke `testPostIsCreatedCorrectly` and `testWithoutCategoryIsUnclassified` in a new instance of `TBPostTest` for each test.
3. **Test 1 (`testPostIsCreatedCorrectly`)**  
   * Creates a `TBPost` via the class‑side convenience method `title:text:category:`.  
   * Asserts that the `title` and `text` properties of the instance match the supplied values.  
4. **Test 2 (`testWithoutCategoryIsUnclassified`)**  
   * Creates a `TBPost` via `title:text:` (no category argument).  
   * Asserts that the `title` is correct, that `isUnclassified` returns `true`, and that `isVisible` returns `false`.  

No explicit setup/cleanup code is needed because each test creates its own `TBPost` instance and the default Smalltalk test harness handles object isolation.

### Assumptions & Constraints
* `TBPost` implements the following API:
  * `title:text:category:` – creates a post with a given title, text, and category.
  * `title:text:` – creates a post without a category (defaults to unclassified).
  * `title`, `text` accessors.
  * `isUnclassified` and `isVisible` predicates.
* The tests assume that a post created without a category automatically has `isUnclassified = true` and `isVisible = false`.
* No external services or resources are required; all tests are purely in-memory.

## 3. Functions/Methods
| Method | Purpose | Inputs | Outputs | Side‑Effects |
|--------|---------|--------|---------|--------------|
| `testPostIsCreatedCorrectly` | Verifies that a `TBPost` created with a category correctly stores title and text. | None (uses hard‑coded literals). | None. | Creates a `TBPost` instance; performs two equality assertions. |
| `testWithoutCategoryIsUnclassified` | Verifies that a `TBPost` created without a category is marked as unclassified and invisible. | None (uses hard‑coded literals). | None. | Creates a `TBPost` instance; performs three assertions. |

There are no helper methods; each test is self‑contained.

## 4. Dependencies
| Dependency | Type | Notes |
|------------|------|-------|
| `TestCase` (Pharo standard library) | Framework | Provides the test harness and assertion methods (`assert:`, `deny:`). |
| `TBPost` (application class) | Application | The class under test; must expose the API used by the tests. |
| Category `TinyBlog-Tests` | Pharo categorization | No functional impact; used for organization. |

No third‑party libraries or platform‑specific APIs are referenced.

## 5. Additional Notes
### Strengths
* **Simplicity** – Tests are straightforward and focused on a single behavior each, making them easy to understand and maintain.
* **Use of assertions** – Leverages Pharo’s expressive assertion syntax (`assert: equals:`).

### Potential Issues & Edge Cases
* **Hard‑coded strings** – If the `TBPost` implementation changes (e.g., title normalization, trimming), the tests may need updating.
* **Missing category assertion** – `testPostIsCreatedCorrectly` never verifies that the `category` property is set correctly. Adding an assertion for `post category` would strengthen the test.
* **No cleanup** – Not required here, but if `TBPost` interacts with a database or file system, a teardown routine would be necessary.
* **Predicate naming** – The test assumes `isUnclassified` and `isVisible` are the correct method names. If these change, the test will fail silently. Consider using explicit property checks or a more descriptive method name.

### Suggested Enhancements
1. **Extract a `setUp` helper** – If more tests are added, initialize common test data in a `setUp` method to avoid duplication.
2. **Verify category handling** – Add an assertion that the category is correctly stored and accessible (`self assert: post category equals: 'TinyBlog'`).
3. **Test edge conditions** – Add tests for empty or `nil` title/text, whitespace handling, and category case sensitivity.
4. **Use constants** – Define test strings as class variables or constants for reuse and clearer intent.
5. **Add `tearDown` if needed** – In case `TBPost` has side effects (e.g., writes to a log or a DB), ensure proper cleanup.

Overall, the test suite is a solid starting point but could benefit from a few minor improvements to increase coverage and resilience to future changes.

## Code Critique



## Code Preview

```smalltalk
Class {
	#name : #TBPostTest,
	#superclass : #TestCase,
	#category : #'TinyBlog-Tests'
}

{ #category : #tests }
TBPostTest >> testPostIsCreatedCorrectly [

	| post |
	post := TBPost 
		title: 'Welcome to TinyBlog' 
		text: 'TinyBlog is a small blog engine made with Pharo.' 
		category: 'TinyBlog'.
	self assert: post title equals: 'Welcome to TinyBlog' .
	self assert: post text equals: 'TinyBlog is a small blog engine made with Pharo.' .
]

{ #category : #tests }
TBPostTest >> testWithoutCategoryIsUnclassified [

	| post |
	post := TBPost 
		title: 'Welcome to TinyBlog' 
		text: 'TinyBlog is a small blog engine made with Pharo.'.
	self assert: post title equals: 'Welcome to TinyBlog' .
	self assert: post isUnclassified.
	self deny: post isVisible
]



```
