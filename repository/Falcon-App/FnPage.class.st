Class {
	#name : #FnPage,
	#superclass : #CynPage,
	#category : #'Falcon-App-View'
}

{ #category : #testing }
FnPage class >> isMainPage [

	"Answer whether the receiver is a main page"

	^ false
]

{ #category : #testing }
FnPage >> isMainPage [

	"Answer whether the receiver is a main page"

	^ self class isMainPage
]

{ #category : #'view - customization' }
FnPage >> toolbarStartButtons [

	"Answer the toolbar buttons for the receiver.
	Show the menu button on a main page, otherwise use default."

	^ self isMainPage
		ifTrue: [ Array with: IonMenuButton new ]
		ifFalse: [ super toolbarStartButtons ]
]
