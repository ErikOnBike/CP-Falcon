Extension { #name : #FnRepository }

{ #category : #'*Falcon-App' }
FnRepository >> doLog [

	^ self restApiClient
		patchUri: self doLogUri body: nil timeoutPeriod: self restTimeoutPeriod
]

{ #category : #'*Falcon-App' }
FnRepository >> doLogUri [

	^ '{1}/log' format: { self uri }
]

{ #category : #'*Falcon-App' }
FnRepository >> doPull [

	^ self restApiClient
		patchUri: self doPullUri body: nil timeoutPeriod: self restTimeoutPeriod
]

{ #category : #'*Falcon-App' }
FnRepository >> doPullUri [

	^ '{1}/pull' format: { self uri }
]

{ #category : #'*Falcon-App' }
FnRepository >> restTimeoutPeriod [

	"Allow extra time for operations"

	^ 30000
]

{ #category : #'*Falcon-App' }
FnRepository class >> uri [

	^ '/repositories'
]
