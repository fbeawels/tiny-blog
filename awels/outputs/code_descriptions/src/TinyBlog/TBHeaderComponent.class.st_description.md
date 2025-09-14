# TBHeaderComponent.class.st

## Review

## 1. Summary  
**Purpose** – `TBHeaderComponent` is a lightweight, reusable Web Application component that renders the default navigation header for the TinyBlog project. It delegates authentication and navigation responsibilities to other components (`TBAuthentificationComponent` and the owning `component`).  

**Key components**  
| Component | Responsibility | Interaction |
|-----------|----------------|-------------|
| `TBHeaderComponent` | Renders the navigation bar, brand link, and context‑sensitive buttons (admin link or login modal). | Uses the *component* instance to access application URL, session state, and to forward navigation actions. |
| `TBAuthentificationComponent` | Provides a login form that is rendered inside the modal dialog triggered by the header. | Instantiated via `TBAuthentificationComponent from: component`. |
| `component` (instance variable) | Holds a reference to the “parent” component that owns the header; expected to respond to `goToAdministrationView` and to provide a `url`. | Used to forward navigation callbacks and to create the authentication component. |

**Notable design patterns & libraries**  
* **Factory Method** – The class method `from:` creates and configures a new instance.  
* **Bootstrap (tbs‑prefix)** – The rendering helpers (`tbsNavbar`, `tbsGlyphIcon`, etc.) are part of the TinyBlog bootstrap wrapper, providing CSS‑ready markup.  
* **Web Application Framework** – `WAComponent` is the base class from the Web Application (WA) framework, which handles HTTP request/response lifecycle and template rendering.

---

## 2. Detailed Description  
### Execution Flow  
1. **Initialization**  
   * A consumer calls `TBHeaderComponent from: someComponent`.  
   * A new `TBHeaderComponent` is instantiated, the `component` instance variable is set, and the instance is returned.

2. **Rendering**  
   * The WA framework calls `renderContentOn:`.  
   * `renderContentOn:` builds a Bootstrap navbar (`tbsNavbar beDefault`) containing a container.  
   * Inside the container, `renderBrandOn:` prints the TinyBlog brand link (`self application url`).  
   * `renderButtonsOn:` inspects `self session isLogged`.  
     * If the user is authenticated, `renderSimpleAdminButtonOn:` is invoked – a form with a button that triggers a callback to the parent component’s `goToAdministrationView`.  
     * If not authenticated, `renderModalLoginButtonOn:` is invoked – it renders an instance of `TBAuthentificationComponent` and adds a button that opens a Bootstrap modal (`data-toggle="modal"`).  
3. **Cleanup** – No explicit cleanup logic is required; WA handles component lifecycle.

### Dependencies & Constraints  
* **WAComponent** – Provides `renderContentOn:`, `session`, and `application` accessors.  
* **Bootstrap Wrapper** – Methods prefixed with `tbs` (e.g., `tbsNavbarButton`) generate Bootstrap‑styled HTML.  
* **Session Object** – Must respond to `isLogged`.  
* **Parent Component** – Must implement `goToAdministrationView` and provide a valid `url`.  

### Design Choices  
* **Separation of Concerns** – Authentication UI is encapsulated in `TBAuthentificationComponent`; navigation logic remains in the parent component.  
* **Conditional Rendering** – The header adapts based on login state, promoting a clean user experience.  
* **Callback Usage** – Admin button uses a WA callback instead of a link, keeping navigation within the same component framework.

---

## 3. Functions/Methods  

| Method | Purpose | Inputs | Outputs / Side‑Effects |
|--------|---------|--------|------------------------|
| `self class >> from: aComponent` | Factory that creates a new header instance and assigns the parent component. | `aComponent` – an instance of the owning component. | New `TBHeaderComponent` with `component := aComponent`. |
| `component` | Getter for the owning component. | None | Returns `component`. |
| `component:` | Setter for the owning component. | `anObject` – the component to attach. | Sets `component`. |
| `renderBrandOn: html` | Renders the brand link (TinyBlog) inside the navbar header. | `html` – an HTML writer. | Writes `<a>` tag with the application URL. |
| `renderButtonsOn: html` | Decides which button(s) to render based on login state. | `html`. | Calls either `renderSimpleAdminButtonOn:` or `renderModalLoginButtonOn:`. |
| `renderContentOn: html` | Main entry point for rendering the component. | `html`. | Builds the full navbar structure. |
| `renderModalLoginButtonOn: html` | Renders the login button that opens a modal and embeds the authentication form. | `html`. | Writes the modal trigger button and renders `TBAuthentificationComponent`. |
| `renderSimpleAdminButtonOn: html` | Renders a button that forwards to the admin view. | `html`. | Writes a form‑wrapped button with a callback to `component goToAdministrationView`. |

### Notes on Reusable/Utility Methods  
* `renderModalLoginButtonOn:` and `renderSimpleAdminButtonOn:` are small, composable helpers that can be reused in other navbar components if needed.

---

## 4. Dependencies  
| Dependency | Type | Notes |
|------------|------|-------|
| `WAComponent` | Core WA framework | Provides the component lifecycle and rendering hooks. |
| `tbs*` helpers (`tbsNavbar`, `tbsGlyphIcon`, etc.) | Third‑party UI wrapper | Likely part of TinyBlog’s Bootstrap abstraction; not standard WA. |
| `TBAuthentificationComponent` | Project‑specific component | Must be loaded; provides login form. |
| `session` object | WA session | Expected to answer `isLogged`. |
| `component` interface (`goToAdministrationView`, `url`) | Project‑specific contract | The parent component must implement these. |

No platform‑specific dependencies are evident beyond the WA web stack.

---

## 5. Additional Notes  

### Edge Cases & Potential Issues  
1. **Duplicate Method** – There is a method named `rendeModalLoginButtonOn:` (misspelled) defined before `renderModalLoginButtonOn:`. It is unused and likely an accidental duplicate. It can be removed to avoid confusion.  
2. **Missing `isLogged` Implementation** – The code assumes that `self session isLogged` returns a Boolean. If the session object does not provide this method, a runtime error will occur.  
3. **Callback vs Link** – The admin button uses a form with a callback. If the application expects a traditional hyperlink, the form may be unnecessary and could introduce a page reload if not handled correctly by WA.  
4. **Modal Target** – The login button references `data-target="#myAuthDialog"`; ensure that a corresponding modal element with that ID exists elsewhere in the page.  
5. **Session State Refresh** – If the session state changes (e.g., after login), the component needs to be re‑rendered to switch from the login button to the admin button. This is typically handled by WA’s reactivity but should be verified.

### Future Enhancements  
* **Extract Button Rendering into Separate Components** – For larger projects, moving the admin and login button logic into their own components would improve modularity.  
* **Add Unit Tests** – Small tests verifying that the correct button is rendered for logged‑in vs. guest users would increase confidence.  
* **Accessibility Improvements** – Ensure that the modal and button markup includes proper ARIA attributes.  
* **Error Handling** – Gracefully handle missing `component` or `TBAuthentificationComponent` to avoid null‑pointer exceptions.  

Overall, the class is concise and leverages WA’s rendering facilities effectively, but it would benefit from cleaning up the duplicated method, confirming session contract, and optionally modularizing the button logic.

## Code Critique



## Code Preview

```smalltalk
"
I am a simple component to manage the default header.
I am factorised on ScreenComponent.
 
"
Class {
	#name : #TBHeaderComponent,
	#superclass : #WAComponent,
	#instVars : [
		'component'
	],
	#category : #'TinyBlog-Components'
}

{ #category : #'instance creation' }
TBHeaderComponent class >> from: aComponent [
         ^ self new
          component: aComponent;
          yourself
]

{ #category : #accessing }
TBHeaderComponent >> component [
         ^ component
]

{ #category : #accessing }
TBHeaderComponent >> component: anObject [
         component := anObject
]

{ #category : #rendering }
TBHeaderComponent >> rendeModalLoginButtonOn: html [
   html render: (TBAuthentificationComponent from: component).
   html tbsNavbarButton
      tbsPullRight;
      attributeAt: 'data-target' put: '#myAuthDialog';
      attributeAt: 'data-toggle' put: 'modal';
      with: [
         html tbsGlyphIcon iconLock.
         html text: ' Login' ]
]

{ #category : #rendering }
TBHeaderComponent >> renderBrandOn: html [
   html tbsNavbarHeader: [
      html tbsNavbarBrand
         url: self application url;
         with: 'TinyBlog' ]
]

{ #category : #rendering }
TBHeaderComponent >> renderButtonsOn: html [
    self session isLogged
        ifTrue: [ self renderSimpleAdminButtonOn: html ]
		  ifFalse: [ self renderModalLoginButtonOn: html ]  
]

{ #category : #rendering }
TBHeaderComponent >> renderContentOn: html [
    html tbsNavbar beDefault; with: [
       html tbsContainer: [
        self renderBrandOn: html.
        self renderButtonsOn: html
]]
]

{ #category : #rendering }
TBHeaderComponent >> renderModalLoginButtonOn: html [
         html render: (TBAuthentificationComponent from: component).
         html tbsNavbarButton
            tbsPullRight;
            attributeAt: 'data-target' put: '#myAuthDialog';
            attributeAt: 'data-toggle' put: 'modal';
            with: [
               html tbsGlyphIcon iconLock.
               html text: ' Login' ]
]

{ #category : #rendering }
TBHeaderComponent >> renderSimpleAdminButtonOn: html [
        html form: [
        html tbsNavbarButton
          tbsPullRight;
          callback: [ component goToAdministrationView ];
          with: [
              html tbsGlyphIcon iconListAlt.
              html text: ' Admin View' ]]
]



```
