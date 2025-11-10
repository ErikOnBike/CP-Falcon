Class {
	#name : #FnLogoutPage,
	#superclass : #FnPage,
	#category : #'Falcon-App-View'
}

{ #category : #'web resources' }
FnLogoutPage class >> style [

	<webResource: #css>

	^ super style, '
#input-wrapper {
	display: flex;
	flex-direction: column;
	align-items: center;
	margin: 30px max(60px, 10%);
}
#input-wrapper > * {
	margin: 10px 0;
}
#button-wrapper {
	display: flex;
	justify-content: center;
}'
]

{ #category : #'web resources' }
FnLogoutPage class >> template [

	<webResource: #html>

	^ '<ion-header>
	<ion-toolbar>
		<ion-title>Logout</ion-title>
	</ion-toolbar>
</ion-header>
<ion-content>
	<div id="container">
		<div id="input-wrapper">
			<ion-label>Remove data</ion-label>
			<ion-toggle id="remove-data-toggle" checked></ion-toggle>
		</div>
		<div id="button-wrapper">
			<ion-button id="back-button" size="small" color="secondary">Oops, go back</ion-button>
			<ion-button id="logout-button" color="danger" size="small">Logout</ion-button>
		</div>
	</div>
</ion-content>'
]

{ #category : #initialization }
FnLogoutPage >> initializeShadowRoot [

	super initializeShadowRoot.

	(self shadowedElementWithId: #'back-button')
		when: CpClickEvent deferSend: #close to: self.

	(self shadowedElementWithId: #'logout-button')
		when: CpClickEvent deferSend: #logout to: self
]

{ #category : #testing }
FnLogoutPage >> isRemoveDataChecked [

	^ (self shadowedElementWithId: #'remove-data-toggle')
		checked
]

{ #category : #actions }
FnLogoutPage >> logout [

	self isRemoveDataChecked
		ifTrue: [ self app removeData ].

	self app logout
]
