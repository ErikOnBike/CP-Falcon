Class {
	#name : #FnActivateAccountPage,
	#superclass : #FnAccountPage,
	#category : #'Falcon-App-View'
}

{ #category : #'web resources' }
FnActivateAccountPage class >> template [

	<webResource: #html>

	^ '<ion-header>
	<ion-toolbar>
		<ion-title>Activate</ion-title>
	</ion-toolbar>
</ion-header>
<ion-content>
	<div id="container">
		<form id="form">
			<ion-list>
				<ion-item>
					<ion-input id="email" label="Email" type="email" label-placement="stacked" autocomplete="email" placeholder="name@domain.org"></ion-input>
				</ion-item>
				<ion-item>
					<ion-input id="token" label="Code" type="text" label-placement="stacked" autocomplete="one-time-code"></ion-input>
				</ion-item>
			</ion-list>
		</form>
	</div>
</ion-content>'
]

{ #category : #binding }
FnActivateAccountPage >> boundProperties [

	^ super boundProperties,
		#(token)
]

{ #category : #operations }
FnActivateAccountPage >> doOperation [

	^ self doOperation: [ self account activate ]
]

{ #category : #'event handling' }
FnActivateAccountPage >> handleError: anError [

	anError statusCode = CynRestResponseError codeNotFound
		ifTrue: [
			self showIncorrectTokenMessage.
			^ false ].

	anError statusCode = CynRestResponseError codeUnprocessableEntity
		ifTrue: [
			self showReregisterAccount.
			^ false ].

	^ super handleError: anError
]

{ #category : #accessing }
FnActivateAccountPage >> loadingOperationText [

	^ 'Activating account...'
]

{ #category : #view }
FnActivateAccountPage >> showIncorrectTokenMessage [

	self app
		showAlertTitle: 'Activation failed'
		message: 'The combination email address and code does not match'
]

{ #category : #view }
FnActivateAccountPage >> showReregisterAccount [

	self app
		showAlertTitle: 'Activation code is expired'
		message: 'Please re-register'
]

{ #category : #view }
FnActivateAccountPage >> toolbarEndButtonText [

	^ 'Activate'
]
