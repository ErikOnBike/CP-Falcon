Class {
	#name : #BaselineOfFalconApp,
	#superclass : #BaselineOf,
	#category : #BaselineOfFalconApp
}

{ #category : #baselines }
BaselineOfFalconApp >> baseline: spec [

	<baseline>

	spec for: #common do: [

		"Dependencies"
		spec
			baseline: 'CodeParadise' with: [ spec loads: #('default') ; repository: 'github://ErikOnBike/CodeParadise:master' ].

		"Packages"
		spec
			package: 'Falcon-App' with: [ spec requires: #('Falcon-Data') ] ;
			package: 'Falcon-Data' with: [ spec requires: #('Falcon-Model') ] ;
			package: 'Falcon-Model' with: [ spec requires: #('CodeParadise') ] ;
			package: 'Falcon-Build' with: [ spec requires: #('CodeParadise') ].

		"Groups"
		spec 
			group: 'default' with: #( 'Core' );

			group: 'Core' with: #( 'Falcon-App' ) ]
]
