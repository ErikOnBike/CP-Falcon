Class {
	#name : #FnRepository,
	#superclass : #FnEntity,
	#instVars : [
		'#name => CynPropertySlot',
		'#location => CynPropertySlot',
		'#syncedAt => CynPropertySlot'
	],
	#category : #'Falcon-Model-Core'
}

{ #category : #'accessing - generated' }
FnRepository class >> allPropertyNames [

	"Generated code. DO NOT EDIT"

	^ #(id name location syncedAt)
]

{ #category : #'accessing - generated' }
FnRepository class >> readWriteProperties [

	"Generated code. DO NOT EDIT"

	^ #(id name location syncedAt)
]

{ #category : #accessing }
FnRepository >> location [

	^ location
]

{ #category : #accessing }
FnRepository >> name [

	^ name
]

{ #category : #accessing }
FnRepository >> syncedAt [

	^ syncedAt
]
