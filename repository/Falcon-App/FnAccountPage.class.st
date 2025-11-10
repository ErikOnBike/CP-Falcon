Class {
	#name : #FnAccountPage,
	#superclass : #FnPage,
	#category : #'Falcon-App-View'
}

{ #category : #tags }
FnAccountPage class >> isAbstractTag [

	"The method is present to indicate the receiver is abstract.
	This method will NOT be evaluated to decide if the receiver is abstract."
]

{ #category : #tags }
FnAccountPage class >> isMainPage [

	^ true
]

{ #category : #tags }
FnAccountPage class >> isPublic [

	^ true
]

{ #category : #accessing }
FnAccountPage >> account [

	^ model
]

{ #category : #binding }
FnAccountPage >> boundProperties [

	^ super boundProperties,
		#(email)
]

{ #category : #operations }
FnAccountPage >> doOperation [

	self subclassResponsibility
]

{ #category : #'event handling' }
FnAccountPage >> handleSubmitForm [

	self validateModelIfValid: [
		self doOperation
			ifTrue: [ self handleFormSubmitted ] ]
]

{ #category : #testing }
FnAccountPage >> workOnCopy [

	^ false
]
