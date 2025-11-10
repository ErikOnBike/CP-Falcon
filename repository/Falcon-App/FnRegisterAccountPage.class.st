Class {
	#name : #FnRegisterAccountPage,
	#superclass : #FnAccountPage,
	#category : #'Falcon-App-View'
}

{ #category : #'web resources' }
FnRegisterAccountPage class >> template [

	<webResource: #html>

	^ '<ion-header>
	<ion-toolbar>
		<ion-title>Register</ion-title>
	</ion-toolbar>
</ion-header>
<ion-content>
	<div id="container">
		<form id="form">
			<ion-list>
				<ion-item>
					<ion-input id="email" type="email" label-placement="stacked" autocomplete="email" placeholder="name@domain.org"></ion-input>
				</ion-item>
				<ion-item>
					<ion-input id="password" label-placement="stacked" type="password" autocomplete="new-password">
						<ion-input-password-toggle slot="end"></ion-input-password-toggle>				
					</ion-input>
				</ion-item>
			</ion-list>
		</form>
	</div>
</ion-content>'
]

{ #category : #binding }
FnRegisterAccountPage >> boundProperties [

	^ super boundProperties,
		#(password)
]

{ #category : #operations }
FnRegisterAccountPage >> doOperation [

	^ self doOperation: [ self account register ]
]

{ #category : #'event handling' }
FnRegisterAccountPage >> handleFormSubmitted [

	self close
]

{ #category : #'event handling' }
FnRegisterAccountPage >> loadingOperationText [

	^ 'Registering account...'
]

{ #category : #'event handling' }
FnRegisterAccountPage >> toolbarEndButtonText [

	^ 'Register'
]
