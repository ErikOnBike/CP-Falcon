Class {
	#name : #FnFalconWebApplication,
	#superclass : #CynMobileWebApplication,
	#category : #'Falcon-App-Application'
}

{ #category : #accessing }
FnFalconWebApplication class >> allowedPackages [

	"Set the allowed packages for the installation checker.

	Include:
		Package containing the Falcon Model (through FnRepository)"

	^ super allowedPackages, { FnRepository package }
]
