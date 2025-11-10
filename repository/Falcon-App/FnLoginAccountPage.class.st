Class {
	#name : #FnLoginAccountPage,
	#superclass : #FnAccountPage,
	#category : #'Falcon-App-View'
}

{ #category : #'web resources' }
FnLoginAccountPage class >> template [

	<webResource: #html>

	^ '<ion-header>
	<ion-toolbar>
		<ion-title>Login</ion-title>
	</ion-toolbar>
</ion-header>
<ion-content>
	<div id="container">
		<form id="form">
			<ion-list>
				<ion-item>
					<ion-input id="email" label-placement="stacked" type="email" autocomplete="email"></ion-input>
				</ion-item>
				<ion-item>
					<ion-input id="password" label-placement="stacked" type="password" autocomplete="current-password">
						<ion-input-password-toggle slot="end"></ion-input-password-toggle>				
					</ion-input>
				</ion-item>
			</ion-list>
		</form>
	</div>
</ion-content>'
]

{ #category : #binding }
FnLoginAccountPage >> boundProperties [

	^ super boundProperties,
		#(password)
]

{ #category : #view }
FnLoginAccountPage >> close [

	"Close the Page"

	"Reset the password, so it is not kept (too long) in memory"
	self account resetPassword.

	super close
]

{ #category : #operations }
FnLoginAccountPage >> doOperation [

	^ self doOperation: [
		self account login.

		"Reset the password, so it is not kept (too long) in memory"
		self account resetPassword.

		self keepResult ]
]

{ #category : #'event handling' }
FnLoginAccountPage >> handleError: anError [

	anError statusCode = CynRestResponseError codeUnauthorized
		ifTrue: [
			self app
				showAlertTitle: 'Login failed' langText
				message: 'Email address and password combination are unknown' langText.

			^ false ].

	^ super handleError: anError
]

{ #category : #accessing }
FnLoginAccountPage >> loadingOperationText [

	"Answer the text to be shown during (longer) operation"

	^ 'Logging in...'
]

{ #category : #'view - customization' }
FnLoginAccountPage >> toolbarEndButtonText [

	^ 'Login'
]

{ #category : #'view - customization' }
FnLoginAccountPage >> updateAfterNavigate [

	"If through activation a session has become available, close the receiver"

	super updateAfterNavigate.

	CynPropertyEntity restApiClient hasAccessToken
		ifTrue: [
			self account propertyAt: #success put: true.
			self close ]
]
