Class {
	#name : #BaselineOfFalconApp,
	#superclass : #BaselineOf,
	#category : #BaselineOfFalconApp
}

{ #category : #baselines }
BaselineOfFalconApp >> baseline: spec [

	<baseline>

	spec for: #common do: [

		"Packages"
		spec
			package: 'Falcon-App' with: [ spec requires: #('Falcon-Data') ] ;
			package: 'Falcon-Data' with: [ spec requires: #('Falcon-Model') ] ;
			package: 'Falcon-Model' with: [ spec repository: 'github://ErikOnBike/CodeParadise:master' ] ;
			package: 'Falcon-Build' with: [ spec repository: 'github://pharo-contributions/OSSubprocess:master/repository' ].

		"Groups"
		spec 
			group: 'default' with: #( 'Core' ) ;
			group: 'builder' with: #( 'Falcon-Build' ) ;

			group: 'Core' with: #( 'Falcon-App' ) ]
]
