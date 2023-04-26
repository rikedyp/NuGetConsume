# NuGetConsume
Use NuGet packages as dependencies in Dyalog APL applications.

## Usage
The application makes names accessible via the .NET bridge `⎕USING` interface.

### Development
- download libraries as dependencies when Cider project or Tatin package is loaded
- using an Init function, for example as a latent expression (in a workspace or Dyalog config file)
- `⎕USING` statement points to the user's NuGet cache (`.nuget` folder)

### Deployment
For deployment, an application and its dependencies should be packaged into a single folder, or a collection of known locations.

The NuGetConsume system should include a means to declare that we want our NuGet libraries saved/copied to a specific folder and that to be reflected in the relevant `⎕USING` statements.

