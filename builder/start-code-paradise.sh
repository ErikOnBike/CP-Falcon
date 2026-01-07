#!/usr/bin/env bash

# Start the currently available version of CodeParadise
#

# Run parameters for Pharo environment
#VM="./Pharo.app/Contents/MacOS/Pharo --headless"
VM="./Pharo.app/Contents/MacOS/Pharo"
RUN_PHARO="$VM Pharo13.0-SNAPSHOT-64bit-374678e2d5.image"

if [ "$1" = "" ] ; then
	echo "Please provide the baseline as first argument (and the repo as second)"
	exit 1
fi
if [ "$2" = "" ] ; then
	echo "Please provide the repo as second argument"
	exit 1
fi

# Execute a Smalltalk script (on image and then quit)
function smalltalk_execute() {
	RESULT="$($RUN_PHARO eval $1 2>&1 > run.log)"
echo $RESULT
	[[ "$RESULT" != "FAILURE" ]]
	return
}

# Load CodeParadise
function load_code_paradise() {
	BASELINE="${1/\'/\'\'}"
	REPO="${2/\'/\'\'}"
	echo "Baseline [${BASELINE}] repo [${REPO}]"

	SCRIPT="
		| stdout stderr write stdoutWrite stderrWrite applicationServer |

		stdout := VTermOutputDriver stdout.
		stderr := VTermOutputDriver stderr.

		write := [ :value :outputDriver |
			| text |
			text := (value isCollection and: [ value isString not ])
				ifTrue: [
					String streamContents: [ :stream |
						value withIndexDo: [ :each :index | 
							index > 1
								ifTrue: [ stream space ].
							stream nextPutAll: each asString ] ] ]
				ifFalse: [ value asString ].
			outputDriver
				nextPutAll: text ;
				lf ;
				flush.
			self traceCr: text ].
		stdoutWrite := [ :value | write value: value value: stdout ].
		stderrWrite := [ :value | write value: value value: stderr ].

		(Smalltalk isInteractive or: [ Smalltalk isInteractiveGraphic ])
			ifTrue: [ stdoutWrite value: 'Open Transcript'. Smalltalk tools openTranscript ].

		stdoutWrite value: 'Load CP-ClientEnvironment'.
		Metacello new 
			baseline: 'CpClientEnvironment' ;
			repository: 'gitlocal://repos/cp-client-environment' ;
			onConflictUseIncoming ;
			load.

		stdoutWrite value: 'Load CodeParadise'.
		Metacello new 
			baseline: 'CodeParadise' ;
			repository: 'gitlocal://repos/code-paradise' ;
			onConflictUseIncoming: #('zinc') useLoaded: #('CpClientEnvironment') ;
			load.
		stdoutWrite value: 'All code loaded'.

		stdoutWrite value: 'Loading OSSubprocess'.
		Metacello new
			baseline: 'OSSubprocess';
			repository: 'github://pharo-contributions/OSSubprocess:master/repository';
			onConflictUseIncoming ;
			load.

		stdoutWrite value: 'Load App'.
		Metacello new 
			baseline: '${BASELINE}' ;
			repository: 'gitlocal://repos/${REPO}' ;
			onConflictUseLoaded ;
			load.

		stdoutWrite value: 'Registering all applications'.
		(Smalltalk classNamed: #CpServerApplication) allSubclasses do: [ :each |
			each hasAbstractTag
				ifFalse: [ each register ] ].

		stdoutWrite value: 'Setting environment to production'.
		(Smalltalk classNamed: #CpServerEnvironment) beProduction.

		stdoutWrite value: 'Start application server'.
		applicationServer := (Smalltalk classNamed: #CpApplicationServerStarter)
			startUsingConfig: {
				#portNumber -> 9999.
				#staticFilesDirectoryName -> 'repos/cp-client-environment/html'.
				#clientErrorHandler -> self
			} asDictionary.

		stdoutWrite value: 'Let WebApplications add local resources'.
		(Smalltalk classNamed: #CpWebApplication) allSubclasses do: [ :each |
			each hasAbstractTag
				ifFalse: [ each addWebResourcesDelegateTo: applicationServer server ] ].

		stdoutWrite value: { 'Server running:' . applicationServer server isRunning }.

		applicationServer server isRunning
			ifNotNil: [ stderrWrite value: 'SUCCESS' ]
			ifNil: [ stderrWrite value: 'FAILURE' ]"

	echo "Loading CodeParadise"
	if ! smalltalk_execute "$SCRIPT" ; then
		echo "Failed to load CodeParadise"
		exit 1
	fi
}

# Load CodeParadise
load_code_paradise $1 $2
