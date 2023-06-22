NuGetConsume
- needs a better name

Class - allows hiding internals
- could do this with public Functions, while "private" methods are hidden under another namespace?
Do we need inheritance?
- if we were to make some generic "dependency" Class

Cider project / Tatin package can depend on NuGet package or generally on .NET dlls of known location?




Options in a namespace
`ng ← ⎕NS'NuGetConsume'`

`ng ← ⎕NEW NuGetConsume options`

`ng ← NuGetConsume.New options`
ng.Packages←   ⍝ list of package names? versions?

Requirements / user story:

dep/deps: .NET dependency
dist: distribution

- user writing APL code wants to use some dep which is not included with 
- user wants to tell the system where this dep comes from, and have the system handle figuring out what ⎕USING should be.
- user should be able to either declare ⎕USING once at top of program, or get ⎕USING for individual deps.
- user should be able to specify specific versions of packages and/or .NET runtimes to use / target.




dotnet CLI methods to wrap:
- restore

## Developing with a .NET package
- I supply the package name and version number
- I use some compatible version of the package while developing
- I can optionally choose a specific DLL according to one of the options listed in the NuGet package's Frameworks tab

## Exporting my project for use by others
- user is expected to install, like doing `npm i`
- DLLS for specific or combination of .NET runtimes are supplied with my distribution
- some DLLs come with, others to be installed

Opinionated:
- config in a config file
- that's it.

- If we provide an "Export" method then the user can do that in their build functions in APL
- If we have targets in the config file then the user needs to access that somehow...

## Config
```
packages: {
	"pkg": "x.y.z",
},
targets: [
	"auto",   // Dependencies are resolved by fetching packages from NuGet when application is first run
	"6.0",    // Copy DLLs compatible with this version of .NET (what about platforms?)
]
```

## Usage
Create a dependencies configuration file. It is best to place this in a dedicated folder within your project directory structure.

- Doesn't have to be called that - point `New` to the config file and it can infer the directory.

### With the project namespace
```
]get NGS
net ← NGS.New 'path/to/folder'
net.Restore
⎕USING ← net.Using''   ⍝ All packages
⎕USING ← net.Using'Clock'
```

### Export
`NGS.Export'target'` will return a namespace configured for the target specified.

### Packaging DLLs with my project
During a project build, `NGS.Export` copies DLLs into a specified folder and stores the relative paths which can be accessed by `NGS.Using`.

### End user installs packages
This is similar to how the end user of a node package uses `npm install` when they obtain a package.

## Features
- NGS gives correct path including slashes depending on currently running operating system

## Targets

### Auto
`ngc ← ngc.Export'auto'`

`ngc` expects 

`ngc.Restore` will create or use an existing .NET project in the folder specified when `ngc` was created. Then why not provide `path` to `NGC.Restore` directly? Because you want a single instance to have multiple export targets.

A NGC instance is tied to a directory. Should the .NET project be shipped, even if we are explicitly copying our dependency DLLs?

Because DLLs or .NET projects are files on the file system, it is reasonable that NGC instances are controlled by a config file in a directory.

`ngc ← NGC.Restore'path/to/folder'`

`ngc.Using'blah'`.

### Specific .NET version
`ngc ← NGC.Restore'

## Tests
```
      ngc←NGC.New'tests/clock/clock.json5'
      ngc.pkg
┌─────┬─────┐
│Clock│1.0.3│
└─────┴─────┘
```