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

{ #category : #'API - repositories' }
FnFalconRestApiService >> gitCommand [

	"Answer the git command (with additional space to allow arguments to be appended directly)"

	^ (config at: #'git-location'), '/git '
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

	stats := CpNodeJSFS namespace statSync: gitDir options: { #bigint -> false } asDictionary.

	^ stats mtime dateAndTimeString
]

{ #category : #API }
FnFalconRestApiService >> logRepository: aRestRequest response: aServerResponse [

	<patch: '/api/repositories/:id/log'>

	| id |

	id := aRestRequest pathParameterAt: #id.

	self logRepositoryWithId: id response: aServerResponse
]

{ #category : #'API - repositories' }
FnFalconRestApiService >> logRepositoryWithId: aString response: aServerResponse [

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
				response: aServerResponse ]
]

{ #category : #API }
FnFalconRestApiService >> pullRepository: aRestRequest response: aServerResponse [

	<patch: '/api/repositories/:id/pull'>

	| id |

	id := aRestRequest pathParameterAt: #id.

	self pullRepositoryWithId: id response: aServerResponse
]

{ #category : #'API - repositories' }
FnFalconRestApiService >> pullRepositoryWithId: aString response: aServerResponse [

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
				response: aServerResponse ]
]
