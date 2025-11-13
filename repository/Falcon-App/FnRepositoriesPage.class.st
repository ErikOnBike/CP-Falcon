Class {
	#name : #FnRepositoriesPage,
	#superclass : #FnPage,
	#instVars : [
		'domUpdater'
	],
	#category : #'Falcon-App-View'
}

{ #category : #testing }
FnRepositoriesPage class >> isMainPage [

	^ true
]

{ #category : #'web resources' }
FnRepositoriesPage class >> template [

	<webResource: #html>

	^ '<ion-header>
	<ion-toolbar>
		<ion-title>Repositories</ion-title>
	</ion-toolbar>
</ion-header>
<ion-content>
	<ion-refresher id="refresher" slot="fixed">
		<ion-refresher-content></ion-refresher-content>
	</ion-refresher>
	<ion-list id="repository-list">
		<template>
			<ion-item button="true" detail="true" event-click="{{click}}">
				<span>{{name}}</span>
				<ion-note slot="end">{{syncedAt}}</ion-note>
			</ion-item>
		</template>
	</ion-list>
</ion-content>'
]

{ #category : #'event handling' }
FnRepositoriesPage >> handleRefreshAction [

	self app loadDataRepositories.

	self updateView
]

{ #category : #'event handling' }
FnRepositoriesPage >> handleRepositoryClicked: aRepository [

	| page |

	page := self app
		showPage: FnRepositoryPage
		withModel: aRepository.

	page when: CynPageClosed deferSend: #handleRefreshAction to: self
]

{ #category : #'event handling' }
FnRepositoriesPage >> initializeShadowRoot [

	super initializeShadowRoot.

	self updateView
]

{ #category : #'event handling' }
FnRepositoriesPage >> release [

	domUpdater ifNotNil: [
		domUpdater release.
		domUpdater := nil ].

	super release
]

{ #category : #accessing }
FnRepositoriesPage >> repositoryList [

	^ self shadowedElementWithId: #'repository-list'
]

{ #category : #'event handling' }
FnRepositoriesPage >> updateBeforeNavigate [

	super updateBeforeNavigate.

	self updateView
]

{ #category : #'event handling' }
FnRepositoriesPage >> updateRepositories [

	| repositoryList |

	repositoryList := self repositoryList.

	(self extractTemplate: repositoryList) ifNotNil: [ :template |
		domUpdater := CpTemplateBasedDomUpdater on: template ].

	domUpdater
		updateChildrenOf: repositoryList
		with: (self app repositories)
		accessor: [ :repository | CynDomUpdaterPropertyModel on: repository
			overrides: {
				self when: #click deferSend: #handleRepositoryClicked: with: repository } ]
]

{ #category : #view }
FnRepositoriesPage >> updateView [

	self updateRepositories
]
