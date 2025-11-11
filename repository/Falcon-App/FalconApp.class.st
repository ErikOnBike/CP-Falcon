Class {
	#name : #FalconApp,
	#superclass : #CynAccountApp,
	#instVars : [
		'repositories'
	],
	#category : #'Falcon-App-View'
}

{ #category : #'class initialization' }
FalconApp class >> beLoaded [

	"Alphabetically ordered references to the required classes.
	(This is not a complete list, other classes are referenced in the superclass or code directly)"

	IonRefresher beLoaded.
	IonRefresherContent beLoaded.

	IonItemSliding beLoaded.
	IonSwipeEvent beLoaded.

	CpClassedAttributeDataUpdater beLoaded.
	CpStyleAttributeDataUpdater beLoaded.
	CpPropertyAttributeDataUpdater beLoaded.
	CpEventAttributeDataUpdater beLoaded
]

{ #category : #'accessing - text' }
FalconApp class >> constraintTexts [

	"Answer Dictionary with constraint texts"

	<languageResource>

	^ super constraintTexts
		at: #'constraint.user' put: 'Unsupported user' ;
		yourself
]

{ #category : #'web resources' }
FalconApp class >> globalStyle [

	<webResource: #css>

	^ super globalStyle, '
@media screen and (min-width: 940px) {
	body {
		transition: background-color 1s;
		background-color: var(--ion-background-color);
	}
	body.thin {
		background-color: #999;
	}
	ion-app {
		transition: left 1s, right 1s, background-color 1s;
	}
	html body.thin ion-app {
		left: calc((100% - 940px) / 2);
		right: calc((100% - 940px) / 2);
	}
}'
]

{ #category : #'class initialization' }
FalconApp class >> postInstall [

	self traceCr: 'In FalconApp'.

	super postInstall
]

{ #category : #'class initialization' }
FalconApp class >> startInstance [

	self traceCr: 'In FalconApp'.

	super startInstance
]

{ #category : #accessing }
FalconApp class >> version [

	^ 'v0.0.1'
]

{ #category : #private }
FalconApp >> dataMerge: newCollection into: existingCollection [

	| existingIndex existingItem |

	"Create or update elements from the new collection into the existing collection"
	newCollection withIndexDo: [ :eachNew :newIndex |
		existingIndex := existingCollection findFirst: [ :eachExisting | eachExisting id = eachNew id ].
		existingIndex > 0
			ifTrue: [
				"Move the existing into the new position"
				existingItem := existingCollection add: (existingCollection removeAt: existingIndex) beforeIndex: newIndex.

				"Merge the content of the new element into the existing one"
				existingItem merge: eachNew ]
			ifFalse: [
				"Add the new into the new position"
				existingCollection add: eachNew beforeIndex: newIndex ] ].

	"Remove any remaining elements"
	[ existingCollection size > newCollection size ] whileTrue: [
		existingCollection removeLast ]
]

{ #category : #'event handling' }
FalconApp >> handleSelectMenuItem: aClickEvent [

	| pageClassName |

	pageClassName := (aClickEvent currentTarget id) withoutPrefix: #'menu-'.

	self menuClose.

	(Smalltalk classNamed: pageClassName) ifNotNil: [ :pageClass |
		self navigateTo: pageClass ]
]

{ #category : #accessing }
FalconApp >> homePageClass [

	^ FnRepositoriesPage
]

{ #category : #initialization }
FalconApp >> initialize [

	super initialize.

	CynPropertyEntity restApiClient hasAccessToken
		ifFalse: [ ^ self ].

	self loadData
]

{ #category : #initialization }
FalconApp >> loadApp [

	super loadApp.

	"Make the app (all pages) thin"
	CpHtmlElement documentBody
		addClass: #thin
]

{ #category : #actions }
FalconApp >> loadData [

	"Load data (make it failsafe when no data connection is available).

	Implementation:
	Order of loading is important, since there are references between models."

	self
		loadDataRepositories
]

{ #category : #actions }
FalconApp >> loadDataRepositories [

	"Load data (make it failsafe when no data connection is available)"

	self traceCr: 'Reading repositories'.
	[
		repositories ifNil: [ repositories := OrderedCollection new ].
		self dataMerge: (FnRepository restRead asOrderedCollection) into: repositories
.self traceCr: repositories printString.
	] on: Error do: [ :err | self warnCr: 'Unable to read repositories: ', err printString ]
]

{ #category : #initialization }
FalconApp >> loadInitialContent [

	super loadInitialContent.

	(CynLoginAccount propertySlotAt: #email)
		addDefinition: FnAccountEmailConstraint default.

	account isLoggedIn
		ifFalse: [ self showLogin ]
]

{ #category : #initialization }
FalconApp >> loadMenu [

	| menuStructure menuContentElement |

	super loadMenu.

	"Create (literal) structure with the menu items.
	Menu items can be #always, #need-login or #when-logged-in indicating how they can be used."
	menuStructure := {
		{ 'logo-github' . FnRepositoriesPage . 'Repositories' }.
		{ 'log-out-outline' . FnLogoutPage . 'Logout' } }.

	menuContentElement := IonContent new
		appendChild: (IonList new
			attributeAt: #inset put: #false ;
			yourself) ;
		yourself.

	menuStructure do: [ :each |
		menuContentElement appendChild: (IonItem new
			id: #'menu-', each second name ;
			href: each first ;
			detail: false ;		"prevent showing the chevron-right"
			appendChild: (IonIcon named: each first) atSlotNamed: #start ;
			appendChild: (IonText textContent: each third) ;
			when: CpClickEvent deferSend: #handleSelectMenuItem: to: self ;
			fullStopWhen: CpClickEvent ;
			yourself) ].

	menu appendChild: menuContentElement.
	(menu firstDescendantMatching: IonTitle asCssSelector) ifNotNil: [ :title |
		title textContent: 'Falcon' ]
]

{ #category : #actions }
FalconApp >> makeTopPage: aPage [

	"Make the specified page the top page"

	| actions |

	"Skip if already top page"
	aPage nextSibling
		ifNil: [ ^ self ].

	"Remove page from navigation stack (remember Ionic is 0-based for indexing)"
	actions := Array new: 2.
	actions at: 1 put: (navigation removeIndex: aPage indexInParent - 1 removeCount: 1 opts: { #animated -> false } asDictionary).

	"Add page on top"
	actions at: 2 put: (navigation push: aPage).

	aPage updateBeforeNavigate.
	(CpJavaScriptPromise allSettled: actions) await.
	aPage updateAfterNavigate
]

{ #category : #actions }
FalconApp >> performUpdateVersion [

	self
		confirm: 'A new version of Falcon is available'
		action: 'Install new version'
		onConfirm: [ CpBrowserDocument current location reload ]
]

{ #category : #removing }
FalconApp >> removeData [

	"Remove any data from memory"

	CynPropertyEntity restApiClient
		removeData.

	account removeData.
	repositories removeData.

	3 timesRepeat: [ Smalltalk garbageCollect ]
]

{ #category : #accessing }
FalconApp >> repositories [

	^ repositories
]

{ #category : #actions }
FalconApp >> showLogin [

	self showModal: FnLoginAccountPage withModel: account.

	account isLoggedIn
		ifTrue: [ self loadData ]
		ifFalse: [ self showLogin ]
]

{ #category : #actions }
FalconApp >> showPage: aPageClass withModel: aModel [

	"Show the specified Page with the (optional) Model.
	It is assumed, that all checks have already been performed with respect to navigation.
	Answer the page shown."

	"Check if a similar (main) page is already open and re-use it"
	aPageClass isMainPage
		ifTrue: [
			navigation children do: [ :each |
				each class = aPageClass
					ifTrue: [

						"Update the model"
						each model: aModel.

						"Bring page to front"
						self makeTopPage: each.

						^ each ] ] ].

	^ super showPage: aPageClass withModel: aModel
]
