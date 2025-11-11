Class {
	#name : #FnFalconRestApiService,
	#superclass : #CynLocalAccountRestApiService,
	#category : #'Falcon-Data-Service'
}

{ #category : #'class initialization' }
FnFalconRestApiService class >> beLoaded [

	CpNodeJSFSDir beLoaded.
	CpNodeJSFSDirent beLoaded
]

{ #category : #'API - repositories' }
FnFalconRestApiService >> allRepositories [

	| dir repositories |

	dir := CpNodeJSFS namespace openDirSync: (config at: #'repositories-location') options: { #recursive -> false } asDictionary.
dir consoleLog.
	repositories := OrderedCollection new.

	dir directoriesDo: [ :each |
		repositories add: {
			#id -> each name.
			#name -> each name.
			#syncedAt -> (self lastUpdatedDirent: each) } asDictionary ].

	^ repositories asArray
]

{ #category : #API }
FnFalconRestApiService >> getRepositories: aRestRequest response: aServerResponse [

	<get: '/api/repositories'>

	self send: self allRepositories response: aServerResponse
]

{ #category : #API }
FnFalconRestApiService >> syncRepository: aRestRequest response: aServerResponse [

	<patch: '/api/repositories/:id/sync'>

	self sendEmptyResponse: aServerResponse
]
