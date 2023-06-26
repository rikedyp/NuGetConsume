NuGetConsume
- needs a better name
	- DotNetDepend
	- UsingDotNet
	- NuGetAPL
	- GetNuGet
	- GetDotNet
	- NGC?

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
Packages may be specified as follows:

- Must have a package name. This is the name listed on the NuGet repository.
- Optionally may specify a version
- Optionally may specify the path to a **.dll** file

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

!!!Note
	Updates to packages are explicit

```
]Get NGC
]Tatin.InstallPackages NGC
NGC.Install packages
NGC.Restore
```

Restore dependencies from a dotnet project:

```
NGC.Restore'/path/to/project.csproj'
```

### In the session
1. User installs packages
2. User sets `⎕USING`
3. User uses packages

### In an application
1. During development, user installs packages
2. When opening the project for development, call `NGC.Restore` to make sure dependencies are installed
3. Call `⎕USING`
	- `⎕USING` has namespace scope, so you could call it once and establish in the root namespace
	- Or set `⎕USING`
	There may be slight negative performance impacts for repeatedly setting `⎕USING`, but you might find it useful for the source code to state explicitly which packages are available, and also to prevent name conflicts in other parts of your application.

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

Export dependencies by copying dotnet project to a directory:
`NGC.Export 'dir'`  

Export dependencies by copying DLLs and package config to a directory:
`NGC.Export 'dir' 'target_framework'`

You might need to install additional an .NET SDK in order to target a specific .NET version (framework). These can be [downloaded from Microsoft](https://dotnet.microsoft.com/en-us/download/visual-studio-sdks?cid=msbuild-developerpacks).

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

NGC.New [config JSON file or namespace]
NGC.AddPackages [packages matrix]
NGC.Restore [dir]
NGC.Export

NuGetConsume is a tool for managing .NET dependencies in Dyalog APL.

An NGC instance is linked to a DotNet project, which may have none or several packages as dependencies.
- What does that mean? That means that an instance of NGC will create a dotnet project in a folder
	- If no folder is specified, we use a temporary path recommended by .NET
	- Otherwise, use the specified folder

UsingNuGet


API:
- could be a namespace containing all config
- could be functions which take paths to config as arguments?




Usage scenarios

- in session
- part of generic project
- part of cider project
- part of tatin package

NGC.Install packages
NGC.Using list_of_packages

## Versions
- latest version (default)
- this version or greater
- this version exactly

Package versions are specified using the NuGet version ranges interval notation which is [summarised on the NuGet documentation website](https://learn.microsoft.com/en-us/nuget/concepts/package-versioning#version-ranges) and in the table below:

|Notation|Applied rule|Description|
|---|---|---|
|`1.0`|`x ≥ 1.0`|Minimum version, inclusive|
|`[1.0,)`|`x ≥ 1.0`|Minimum version, inclusive|
|`(1.0,)`|`x > 1.0`|Minimum version, exclusive|
|`[1.0]`|`x == 1.0`|Exact version match|
|`(,1.0]`|`x ≤ 1.0`|Maximum version, inclusive|
|`(,1.0)`|`x < 1.0`|Maximum version, exclusive|
|`[1.0,2.0]`|`1.0 ≤ x ≤ 2.0`|Exact range, inclusive|
|`(1.0,2.0)`|`1.0 < x < 2.0`|Exact range, exclusive|
|`[1.0,2.0)`|`1.0 ≤ x < 2.0`|Mixed inclusive minimum and exclusive maximum version|
|`(1.0)`|invalid|invalid|