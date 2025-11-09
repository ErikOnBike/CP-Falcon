# CP-Falcon
Falcon - App Logistics, Control &amp; Oversight

Falcon is a Canyon based App to be used with [CodeParadise](github://ErikOnBike/CodeParadise). The repository contains the client mobile app
as well as the server backend code.

Both the client image for the mobile app as well as the server image for the REST API service are build on the server by Falcon.
Multiple versions are kept allowing installation of new versions, but also reverting to known versions in case of issues.

Falcon allows to see the state of the running services and allows to restart them manually.

Currently Falcon assumes pm2 is used as the process manager for the (REST API) services.
