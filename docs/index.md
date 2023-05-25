# NuGetConsume

Use NuGet packages as dependencies in Dyalog APL applications.

## To do
- How would someone build separately for multiple .NET targets?

## How it works
NuGet packages are typically distributed as shared objects (.dll, .so, .dylib) which are accessed in Dyalog APL via the [`⎕USING`](#) interface.

NuGetConsume will establish a .NET project in a folder which will then have packages. This is all done via the `dotnet` CLI.

![CLI]: Command Line Interface

## Install
```
]Tatin.Installpackages [tatin-test]/NuGetConsume
```

## Usage

### Set up
Dependencies are declared in a JSON5 file. The file defines an object in which every key is the name of a NuGet package and every corresponding value is a version number. Currently NuGetConsume only supports depending on exact versions of packages.

`ng ← NuGetConsume.Init '/path/to/project/nuget/'`

Call `NuGetConsume.Init` with the path to your NuGet dependencies folder as argument. This is usually a subfolder of your APL project. Conventionally, it is at the same level as your `APLSource` folder.

The result `ng` is a reference to a namespace which is the interface to your NuGet dependencies.

If there is no `nuget-packages.json5` file in that folder, then you will be asked if you would like to create one. An editor window may be opened at this point.

The dependencies defined in `nuget-packages.json5` will be added to your project. These can be accessed 

### Install packages
An end user may install packages from your dependencies to their local system for use with your APL project. This is similar to `npm install` in the Node Package Manager ecosystem.

### Using the packages
.NET assemblies are accessed via the `⎕USING` interface in Dyalog APL. Setting `⎕USING` will establish names in the current namespace which refer to .NET methods and objects. NuGetConsume stores the paths to the shared objects in the `ng` namespace returned by the `Init` function. The `ng.Using` function returns values which should be used with `⎕USING` before you would like to use the .NET methods and objects.

`usg ← NuGetConsume.Using pkg`

- If pkg is an empty character vector (`''`), then `Using` returns
- If pkg is

```
⎕USING←'System' (ng.Using'')
```



#### Cider/Tatin
NuGetConsume provides the `Using` function which can be used to set `⎕USING` wherever the consuming developer sees fit. However, if you are developing a Cider project, you can set a `nuget` property in the Cider config which points to the NuGetConsume's dependency folder. Then add a call to NuGetConsume.Init in the Cider project's `Init` function so that `⎕USING` is set in the project namespace whenever the project is opened.

Then something needs to be set up so that publishing the package can copy DLLs appropriately ready for the application to be bundled up.

### Load dependencies
