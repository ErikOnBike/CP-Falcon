Class {
	#name : #FnRepositoryPage,
	#superclass : #FnPage,
	#instVars : [
		'domUpdater'
	],
	#category : #'Falcon-App-View'
}

{ #category : #testing }
FnRepositoryPage class >> isModelPage [

	^ true
]

{ #category : #'web resources' }
FnRepositoryPage class >> style [

	<webResource: #css>

	^ super style, '
ion-content {
	max-height: 100%;
}
#container {
	display: flex;
	flex-direction: column;
	max-height: 100%;
}
#buttons {
	display: flex;
	justify-content: center;
	column-gap: 30px;
	margin-bottom: 20px;
}
#buttons ion-button {
	min-width: 10em;
}
#log {
	white-space: pre-line;
	overflow-y: scroll;
}'
]

{ #category : #'web resources' }
FnRepositoryPage class >> template [

	<webResource: #html>

	^ '<ion-header>
	<ion-toolbar>
		<ion-title>Repository</ion-title>
	</ion-toolbar>
</ion-header>
<ion-content>
	<div id="container">
		<form id="form" class="readonly">
			<ion-list>
				<ion-item>
					<ion-input id="name" label-placement="stacked" readonly></ion-input>
				</ion-item>
				<ion-item>
					<ion-input id="syncedAt" label-placement="stacked" readonly></ion-input>
				</ion-item>
			</ion-list>
		</form>
		<div id="log" class="ion-margin-horizontal">
		</div>
		<div id="buttons">
			<ion-button id="pull-button">Pull</ion-button>
			<ion-button id="log-button">Log</ion-button>
		</div>
	</div>
</ion-content>'
]

{ #category : #binding }
FnRepositoryPage >> boundProperties [

	^ super boundProperties,
		#(name syncedAt)
]

{ #category : #'event handling' }
FnRepositoryPage >> handleLogButtonClicked [

	self updateLog: model doLog
]

{ #category : #'event handling' }
FnRepositoryPage >> handlePullButtonClicked [

	self updateLog: model doPull
]

{ #category : #initialization }
FnRepositoryPage >> initializeShadowRoot [

	super initializeShadowRoot.

	self pullButton
		when: CpClickEvent deferSend: #handlePullButtonClicked to: self.

	self logButton
		when: CpClickEvent deferSend: #handleLogButtonClicked to: self
]

{ #category : #accessing }
FnRepositoryPage >> logButton [

	^ self shadowedElementWithId: #'log-button'
]

{ #category : #accessing }
FnRepositoryPage >> logElement [

	^ self shadowedElementWithId: #log
]

{ #category : #accessing }
FnRepositoryPage >> pullButton [

	^ self shadowedElementWithId: #'pull-button'
]

{ #category : #view }
FnRepositoryPage >> updateLog: aDictionary [

	| log |

	log := String streamContents: [ :stream |
		aDictionary
			at: #success ifPresent: [ :success |
				success ifNotNil: [
					stream
						nextPutAll: success ;
						lf ] ] ;
			at: #error ifPresent: [ :error |
				error ifNotNil: [
					stream
						nextPutAll: 'ERROR:' ;
						lf ;
						nextPutAll: error ] ] ;
			at: #log ifPresent: [ :text |
				text ifNotNil: [
					stream
						lf ;
						nextPutAll: text ;
						lf ] ] ].

	self logElement textContent: log
]
