Class {
	#name : #FnAccountEmailConstraint,
	#superclass : #CynDefaultPropertyConstraint,
	#category : #'Falcon-Model-Constraints'
}

{ #category : #validating }
FnAccountEmailConstraint >> violationsForValue: aString in: aModel do: aBlock [

	| foundIssues |

	foundIssues := false.
	CynEmailPropertyConstraint default
		violationsForValue: aString in: aModel do: [ :issue |
			aBlock value: issue.
			foundIssues := true ].

	foundIssues
		ifTrue: [ ^ self ].

	aString = 'erik@toolparadise.nl'
		ifFalse: [ aBlock value: #'app.constraint.user' ]
]
