Class {
	#name : #FnRepository,
	#superclass : #FnEntity,
	#instVars : [
		'#name => CynPropertySlot',
		'#location => CynPropertySlot',
		'#syncedAt => CynPropertySlot',
		'#isMobileApp => CynPropertySlot'
	],
	#category : #'Falcon-Model-Core'
}

{ #category : #'accessing - generated' }
FnRepository class >> allPropertyNames [

	"Generated code. DO NOT EDIT"

	^ #(id name location syncedAt isMobileApp)
]

{ #category : #'accessing - generated' }
FnRepository class >> readWriteProperties [

	"Generated code. DO NOT EDIT"

	^ #(id name location syncedAt isMobileApp)
]

{ #category : #accessing }
FnRepository >> isMobileApp [

	^ isMobileApp
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
