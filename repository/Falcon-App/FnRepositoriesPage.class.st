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
			<ion-item-sliding>
				<ion-item button="true" detail="true">
					<span>{{name}}</span>
				</ion-item>
				<ion-item-options slot="end">
					<ion-item-option expandable="" event-click="{{doSync}}" event-ion-swipe="{{doSync}}">Sync</ion-item>
				</ion-item-options>
			</ion-item-sliding>
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
FnRepositoriesPage >> handleRepositorySync: aRepository [

	self repositoryList closeSlidingItems.

	self traceCr: 'Sync repo ', aRepository printString
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

	self repositoryList closeSlidingItems.

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
				self when: #doSync deferSend: #handleRepositorySync: with: repository } ]
]

{ #category : #view }
FnRepositoriesPage >> updateView [

	self updateRepositories
]
