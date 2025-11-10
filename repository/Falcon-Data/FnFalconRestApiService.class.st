Class {
	#name : #FnFalconRestApiService,
	#superclass : #CynLocalAccountRestApiService,
	#category : #'Falcon-Data-Service'
}

{ #category : #API }
FnFalconRestApiService >> getAllRepositories: aRestRequest response: aServerResponse [

	<get: '/api/repositories'>

	self sendEmptyResponse: aServerResponse
]

{ #category : #API }
FnFalconRestApiService >> syncRepository: aRestRequest response: aServerResponse [

	<patch: '/api/repositories/:id/sync'>

	self sendEmptyResponse: aServerResponse
]
