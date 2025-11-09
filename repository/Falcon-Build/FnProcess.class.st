Class {
	#name : #FnProcess,
	#superclass : #Object,
	#instVars : [
		'name',
		'command',
		'arguments',
		'success'
	],
	#category : #'Falcon-Build-Builder'
}

{ #category : #'instance creation' }
FnProcess class >> name: nameString command: commandString arguments: anArray [

	^ self basicNew
		initializeWithName: nameString command: commandString arguments: anArray ;
		yourself
]

{ #category : #'instance creation' }
FnProcess class >> new [

	self errorNewReplacedBy: #name:command:arguments:
]

{ #category : #accessing }
FnProcess >> arguments [

	^ arguments
]

{ #category : #accessing }
FnProcess >> beSuccess [

	success := true
]

{ #category : #accessing }
FnProcess >> command [

	^ command
]

{ #category : #initialization }
FnProcess >> initializeWithName: nameString command: commandString arguments: anArray [

	self initialize.

	name := nameString.
	command := commandString.
	arguments := anArray
]

{ #category : #testing }
FnProcess >> isSuccess [

	^ success == true
]

{ #category : #accessing }
FnProcess >> name [

	^ name
]
