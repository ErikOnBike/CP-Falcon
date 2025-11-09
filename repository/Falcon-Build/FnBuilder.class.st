Class {
	#name : #FnBuilder,
	#superclass : #Object,
	#instVars : [
		'project',
		'applicationServer',
		'stdout',
		'stderr',
		'runningProcess'
	],
	#category : #'Falcon-Build-Builder'
}

{ #category : #building }
FnBuilder class >> buildProject: aString [

	"Build a new set of images (client image and server image) for the specified project"

	^ (self project: aString)
		build ;
		yourself
]

{ #category : #'instance creation' }
FnBuilder class >> new [

	self error: 'Use ', #project:
]

{ #category : #'instance creation' }
FnBuilder class >> project: aString [

	"Answer a new instance of the receiver for the specified project"

	^ self basicNew
		initializeWithProject: aString ;
		yourself
]

{ #category : #building }
FnBuilder >> build [

	[
		self
			validate ;
			setup ;
			loadProjects ;
			startApplication ;
			createClientImage ;
			createServerImage ;
			quit.

		self traceCr: 'SUCCESS'
	] on: Error do: [ :error |
		self
			errorCr: 'Failure when building ', project ;
			errorCr: error printString ;
			removeResults ;
			errorCr: 'FAILED' ;
			quit ]
]

{ #category : #accessing }
FnBuilder >> clearProcess [

	runningProcess := nil
]

{ #category : #accessing }
FnBuilder >> clientImageName [

	"Answer relative path to the client image"

	^ String streamContents: [ :stream |
		stream
			nextPutAll: 'builds/' ;
			nextPutAll: self projectRepoName ;
			nextPutAll: '/app.' ;
			nextPutAll: self projectVersion ;
			nextPutAll: '.image' ]
]

{ #category : #accessing }
FnBuilder >> createCientImageProcess [

	^ FnProcess
		name: 'CreateClientImage'
		command: 'create-client-image.sh'
		arguments: { self projectRepoName . self projectClientVersion . self projectShortName }
]

{ #category : #actions }
FnBuilder >> createClientImage [

	self
		performProcess: self createCientImageProcess
		timeout: 5 minutes
]

{ #category : #actions }
FnBuilder >> createServerImage [

	self
		performProcess: self createServerImageProcess
		timeout: 5 minutes
]

{ #category : #accessing }
FnBuilder >> createServerImageProcess [

	^ FnProcess
		name: 'CreateServerImage'
		command: 'create-server-image.sh'
		arguments: { self projectRepoName . self projectServerVersion . self projectShortName }
]

{ #category : #'input/output' }
FnBuilder >> errorCr: aString [

	stderr
		nextPutAll: aString ;
		flush
]

{ #category : #testing }
FnBuilder >> fileExists: aString [

	| fileReference |

	fileReference := aString asFileReference.

	^ fileReference exists
]

{ #category : #'error handling' }
FnBuilder >> handleClientError: aClientError for: aServerEnvironment [

	"Signal error to stop the build process"

	self error: 'Error in client: ', aClientError printString
]

{ #category : #testing }
FnBuilder >> hasProcess [

	^ runningProcess isNotNil
]

{ #category : #initialization }
FnBuilder >> initialize [

	super initialize.

	stdout := VTermOutputDriver stdout.
	stderr := VTermOutputDriver stderr
]

{ #category : #initialization }
FnBuilder >> initializeWithProject: aString [

	self initialize.

	project := aString
]

{ #category : #actions }
FnBuilder >> loadProjects [

	self traceCr: 'Load CP-ClientEnvironment'.
	Metacello new 
		baseline: 'CpClientEnvironment' ;
		repository: 'gitlocal://repos/cp-client-environment' ;
		onConflictUseIncoming ;
		load.

	self traceCr: 'Load CodeParadise'.
	Metacello new 
		baseline: 'CodeParadise' ;
		repository: 'gitlocal://repos/code-paradise' ;
		onConflictUseIncoming: #('zinc') useLoaded: #('CpClientEnvironment') ;
		load.

	self traceCr: 'Load project ', project.
	Metacello new 
		baseline: project ;
		repository: 'gitlocal://repos/', self projectRepoName ;
		onConflictUseLoaded ;
		load.

	self traceCr: 'All code loaded'
]

{ #category : #actions }
FnBuilder >> performProcess: aProcess timeout: aDelay [

	| completed |

	completed := Semaphore new.

	[
		"Run the process"
		[ self runProcess: aProcess timeout: aDelay ] on: Exception do: [ :exception | self errorCr: 'Running process failed ', exception printString ].

		"Signal the process has completed"
		completed signal
	] fork.

	completed wait.

	aProcess isSuccess
		ifFalse: [ self error: 'Failed to perform process: ', aProcess name ]
]

{ #category : #accessing }
FnBuilder >> projectAppClass [

	^ Smalltalk classNamed: project
]

{ #category : #accessing }
FnBuilder >> projectAppName [

	^ self projectAppClass app
]

{ #category : #accessing }
FnBuilder >> projectClientVersion [

	"Answer the client version.

	Implementation:
	The Client version is set on the App, so it can be tested from within the App.
	(If it were defined on the WebApplication it would not be part of the App.)"

	^ self projectAppClass version
]

{ #category : #accessing }
FnBuilder >> projectRepoName [

	^ project asKebabCase
]

{ #category : #accessing }
FnBuilder >> projectServerApplicationClass [

	| applicationClasses |

	applicationClasses := OrderedCollection new.

	"Because class is not known at startup, use dynamic reference"
	(Smalltalk classNamed: #CynRestHttpServerApplication) allSubclassesDo: [ :each |
		each hasAbstractTag
			ifFalse: [ applicationClasses add: each ] ].

	applicationClasses size = 1
		ifFalse: [ self error: 'The ServerApplication class for ', project, ' is not uniquely defined' ].

	^ applicationClasses first
]

{ #category : #accessing }
FnBuilder >> projectServerVersion [

	"Answer the server version.

	Implementation:
	In contrast with the client version, this is defined on the ServerApplication."

	^ self projectServerApplicationClass version
]

{ #category : #accessing }
FnBuilder >> projectShortName [

	"Short name should answer a name without dashes"

	^ self projectAppName reject: [ :each | each = $- ]
]

{ #category : #accessing }
FnBuilder >> projectVersion [

	^ self projectAppClass version
]

{ #category : #accessing }
FnBuilder >> projectWebApplicationClass [

	| applicationClasses |

	applicationClasses := OrderedCollection new.

	"Because class is not known at startup, use dynamic reference"
	(Smalltalk classNamed: #CynMobileWebApplication) allSubclassesDo: [ :each |
		each hasAbstractTag
			ifFalse: [ applicationClasses add: each ] ].

	applicationClasses size = 1
		ifFalse: [ self error: 'The WebApplication class for ', project, ' is not uniquely defined' ].

	^ applicationClasses first
]

{ #category : #building }
FnBuilder >> quit [

	"Smalltalk quitPrimitive"
]

{ #category : #actions }
FnBuilder >> removeFile: aString [

	"Remove the file with the specified name"

	| fileReference |

	fileReference := aString asFileReference.

	fileReference exists
		ifFalse: [ ^ self ].

	[ aString asFileReference delete ] on: Error do: [ :error |
		"Only write log entry of this failure"
		self errorCr: 'Failed to remove: ', aString ]
]

{ #category : #actions }
FnBuilder >> removeResults [

	self traceCr: 'Removing results'.

	self
		removeFile: self clientImageName ;
		removeFile: self serverImageName
]

{ #category : #actions }
FnBuilder >> runProcess: aProcess timeout: aDelay [

	| maxEndTime |

	self hasProcess
		ifTrue: [
			self errorCr: 'Starting process while previous process has not finished yet'.
			^ self ].

	maxEndTime := DateAndTime now + aDelay.

	OSSUnixSubprocess new
		command: aProcess command ;
		arguments: aProcess arguments ;
		redirectStdout ;
		redirectStderr ;
		runAndWaitPollingEvery: (Delay forMilliseconds: 500) doing: [ :process :outStream :errStream |

			"Pipe output"
			outStream upToEnd ifNotEmpty: [ :outText |
				self traceCr: outText ].
			errStream upToEnd ifNotEmpty: [ :errText |
				self errorCr: errText ].

			"Mark the current process (and check if still the running process for safety measure)"
			(self setProcess: process)
				ifFalse: [
					self errorCr: 'Process ', aProcess name, ' started while ', runningProcess name, ' has not finished. Terminating both...'.
					process terminate.
					self terminateProcess ].

			"Validate we have not reached timeout yet"
			DateAndTime now > maxEndTime
				ifTrue: [
					self errorCr: 'Process ', aProcess name, ' ran more too long. Terminating process...'.
					self terminateProcess ] ]
		onExitDo: [ :process :outStream :errStream  |

			"Keep last piece of output"
			outStream upToEnd ifNotEmpty: [ :outText |
				self traceCr: outText ].
			errStream upToEnd ifNotEmpty: [ :errText |
				self errorCr: errText ].

			"Clean up and show result (incl. clearing internal process to allow new processes to run)"
			process closeAndCleanStreams.
			self traceCr: 'Process ', aProcess name, ' has exited with status: ', process exitStatusInterpreter printString.
			self clearProcess.

			"Mark the Process successful"
			process isSuccess
				ifTrue: [ aProcess beSuccess ] ]
]

{ #category : #accessing }
FnBuilder >> serverImageName [

	"Answer relative path to the server image"

	^ String streamContents: [ :stream |
		stream
			nextPutAll: 'builds/' ;
			nextPutAll: self projectRepoName ;
			nextPutAll: '/server.' ;
			nextPutAll: self projectVersion ;
			nextPutAll: '.image' ]
]

{ #category : #accessing }
FnBuilder >> setProcess: aProcess [

	"Set the specified Process as the running Process.
	Answer a Boolean indicating whether this is successful.
	This is NOT successful if another Process is already running."

	runningProcess ifNil: [
		runningProcess := aProcess.
		^ true ].

	^ runningProcess == aProcess
]

{ #category : #actions }
FnBuilder >> setup [

	self traceCr: 'Setting environment to production'.

	"Because class is not known at startup, use dynamic reference"
	(Smalltalk classNamed: #CpServerEnvironment) beProduction
]

{ #category : #actions }
FnBuilder >> startApplication [

	| webApplicationClass |

	self traceCr: 'Registering application'.
	webApplicationClass := self projectWebApplicationClass.
	webApplicationClass register.

	self traceCr: 'Start application server'.

	"Because class is not known at startup, use dynamic reference"
	applicationServer := (Smalltalk classNamed: #CpApplicationServerStarter)
		startUsingConfig: {
			#portNumber -> 9999.
			#staticFilesDirectoryName -> 'repos/cp-client-environment/html'.
			#clientErrorHandler -> self
		} asDictionary.

	self traceCr: 'Let application add local resource'.
	webApplicationClass addWebResourcesDelegateTo: applicationServer server
]

{ #category : #accessing }
FnBuilder >> terminateProcess [

	runningProcess ifNil: [ ^ self ].

	runningProcess terminate.
	runningProcess := nil
]

{ #category : #'input/output' }
FnBuilder >> traceCr: aString [

	stdout
		nextPutAll: aString ;
		flush
]

{ #category : #actions }
FnBuilder >> validate [

	"Validate the project can be built"

	"Calling this will fail if no WebApplication class can be found"
	self projectWebApplicationClass
]
