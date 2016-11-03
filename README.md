# scripts

Random stuff that I've hacked together.

##Generate Munki ClientConfig
Based on some code from Rich Trouton, asks for a Munki server and manifest name, then builds a nopkg installer to set Munki's `ClientIdentifier` and `SoftwareRepoURL` keys. Assumes you are using a subdirectory of `/munki_repo`; edit if needed.