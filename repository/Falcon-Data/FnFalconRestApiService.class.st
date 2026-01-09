Class {
	#name : #FnFalconRestApiService,
	#superclass : #CynLocalAccountRestApiService,
	#instVars : [
		'fs'
	],
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

	dir := fs openDirSync: (config at: #'repositories-location') options: { #recursive -> false } asDictionary.

	repositories := OrderedCollection new.

	dir directoriesDo: [ :each |
		repositories add: {
			#id -> each name.
			#name -> each name.
			#syncedAt -> (self lastUpdatedDirent: each).
			#isMobileApp -> (self isMobileAppDirent: each) } asDictionary ].

	^ repositories asArray
]

{ #category : #API }
FnFalconRestApiService >> getRepositories: aRestRequest response: aRestResponse [

	<get: '/api/repositories'>

	self send: self allRepositories response: aRestResponse
]

{ #category : #API }
FnFalconRestApiService >> getRepository: aRestRequest response: aRestResponse [

	<get: '/api/repositories/:id'>

	| id |

	id := aRestRequest pathParameterAt: #id.

	self send: (self getRepositoryWithId: id) response: aRestResponse
]

{ #category : #'API - repositories' }
FnFalconRestApiService >> getRepositoryWithId: id [

	| dir |

	dir := fs openDirSync: (config at: #'repositories-location') options: { #recursive -> false } asDictionary.

	dir directoriesDo: [ :each |
		each name = id
			ifTrue: [
				^ {
					#id -> each name.
					#name -> each name.
					#syncedAt -> (self lastUpdatedDirent: each).
					#isMobileApp -> (self isMobileAppDirent: each) } asDictionary ] ].

	CpNodeJSRestNotFoundError signal
]

{ #category : #'API - repositories' }
FnFalconRestApiService >> gitCommand [

	"Answer the git command (with additional space to allow arguments to be appended directly)"

	^ (config at: #'git-location'), '/git '
]

{ #category : #initialization }
FnFalconRestApiService >> initialize [

	super initialize.

	fs := CpNodeJSFS namespace
]

{ #category : #'API - repositories' }
FnFalconRestApiService >> isMobileAppDirent: aDirent [

	| pathPrefix |

	pathPrefix := String streamContents: [ :stream |
		stream
			nextPutAll: aDirent parentPath ;
			nextPut: $/ ;
			nextPutAll: aDirent name ;
			nextPut: $/ ].

	^ (fs isDirectory: pathPrefix, 'server') and: [ fs isDirectory: pathPrefix, 'www' ]
]

{ #category : #'API - repositories' }
FnFalconRestApiService >> lastUpdatedDirent: aDirent [

	| gitDir stats |

	gitDir := String streamContents: [ :stream |
		stream
			nextPutAll: aDirent parentPath ;
			nextPut: $/ ;
			nextPutAll: aDirent name ;
			nextPutAll: '/.git' ].

	stats := fs statSync: gitDir options: { #bigint -> false } asDictionary.

	^ stats mtime dateAndTimeString
]

{ #category : #API }
FnFalconRestApiService >> logRepository: aRestRequest response: aRestResponse [

	<patch: '/api/repositories/:id/log'>

	| id |

	id := aRestRequest pathParameterAt: #id.

	self logRepositoryWithId: id response: aRestResponse
]

{ #category : #'API - repositories' }
FnFalconRestApiService >> logRepositoryWithId: aString response: aRestResponse [

	| process |

	process := CpNodeJSChildProcessModule namespace
		exec: self gitCommand, 'log --max-count=8'
		options: {
			#cwd -> ((config at: #'repositories-location'), '/', aString).
			#timeout -> 20000 } asDictionary
		callback: [ :error :stdout :stderr |
			self
				send: {
						#error -> (error ifNotNil: [ error printString ]).
						#success -> stdout asString.
						#log -> stderr asString } asDictionary
				response: aRestResponse ]
]

{ #category : #API }
FnFalconRestApiService >> pullRepository: aRestRequest response: aRestResponse [

	<patch: '/api/repositories/:id/pull'>

	| id |

	id := aRestRequest pathParameterAt: #id.

	self pullRepositoryWithId: id response: aRestResponse
]

{ #category : #'API - repositories' }
FnFalconRestApiService >> pullRepositoryWithId: aString response: aRestResponse [

	| process |

	process := CpNodeJSChildProcessModule namespace
		exec: self gitCommand, 'pull'
		options: {
			#cwd -> ((config at: #'repositories-location'), '/', aString).
			#timeout -> 20000 } asDictionary
		callback: [ :error :stdout :stderr |
			self
				send: {
						#error -> (error ifNotNil: [ error printString ]).
						#success -> stdout asString.
						#log -> stderr asString } asDictionary
				response: aRestResponse ]
]
