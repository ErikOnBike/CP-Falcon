Class {
	#name : #FnFalconRestHttpServerApplication,
	#superclass : #CynRestHttpServerApplication,
	#category : #'Falcon-Data-Application'
}

{ #category : #accessing }
FnFalconRestHttpServerApplication class >> allowedPackages [

	"Answer a collection of Packages which are allowed to contain classes to install in the receiver"

	^ super allowedPackages, {
		FnRepository package }
]

{ #category : #accessing }
FnFalconRestHttpServerApplication class >> app [

	^ #'falcon-data'
]
