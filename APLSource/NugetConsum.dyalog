﻿:Namespace NugetConsum
    ⎕ML←⎕IO←1
    cutEndAt←{(1-(⌽⍵)⍳⍺)↑⍵}
    subdirs←{(n t)←0 1(⎕NINFO⍠1)⍵,'/*' ⋄ (t=1)/n}
    split←{1↓¨(⍺=⍺,⍵)⊂⍺,⍵}
    trimEndAt←{(-(⌽⍵)⍳⍺)↓⍵}

    :Class Package
        :field public id
        :field public version
        :field public framework
        :field public useNS←''  ⍝ vtv containing namespaces we want to use
        :field public myDLL←''  ⍝ name of the DLL (default: "id")


        cutEndAt←{(1-(⌽⍵)⍳⍺)↑⍵}
        subdirs←{(n t)←0 1(⎕NINFO⍠1)⍵,'/*' ⋄ (t=1)/n}
        split←{1↓¨(⍺=⍺,⍵)⊂⍺,⍵}
        trimEndAt←{(-(⌽⍵)⍳⍺)↓⍵}

        ∇ Init
          id←''
          version←'0.0.0'
          framework←''
        ∇

        ∇ make
          :Access public
          :Implements constructor
          Init
        ∇

        ∇ make1 argid
          :Access public
          :Implements constructor
          Init
          argid←(';'⎕R',')argid
          :If 0<+/','=argid
              (id v)←2↑','split argid
              :If ∨/'Version'⍷v
                  version←{¯1↓⊃,/⍵,¨'.'}3⍴('.'split 2⊃'='split v),⊆'0'
              :Else
                  version←BestVersion
              :EndIf
          :Else
              id←argid
              version←BestVersion
          :EndIf
         
        ∇

        ∇ make2(argid argver)
          :Access public
          :Implements constructor
          Init
          id←argid
          version←argver
        ∇

        ∇ make3(argid argver arguse)
          :Access public
          :Implements constructor
          Init
          id←argid
          version←argver
          useNS←arguse
        ∇
        ∇ make4(argid argver arguse argdll)
          :Access public
          :Implements constructor
          Init
          id←argid
          version←argver
          useNS←arguse
          myDLL←argdll
        ∇



        ∇ r←Versions;pckgs;pckg
          :Access public
          ⎕USING←'System'
          up←Environment.GetFolderPath Environment.SpecialFolder.UserProfile
          pckgs←up,'/.nuget/packages'
          ('global-cache not found (',pckgs,')')⎕SIGNAL(~⎕NEXISTS pckgs)/19
          pckg←pckgs,'/',id
          ('package not found (',pckg,')')⎕SIGNAL(~⎕NEXISTS pckg)/19
          r←'/'cutEndAt¨subdirs pckg
        ∇

        ∇ r←Frameworks;pckgs;pckg;pckgver;av
          :Access public
          ⎕USING←'System'
          up←Environment.GetFolderPath Environment.SpecialFolder.UserProfile
          pckgs←up,'/.nuget/packages'
          ('global-cache not found (',pckgs,')')⎕SIGNAL(~⎕NEXISTS pckgs)/19
          pckg←pckgs,'/',id
          ('package not found (',pckg,')')⎕SIGNAL(~⎕NEXISTS pckg)/19
          pckgver←pckg,'/',version
          ('package version not found (',pckgver,')')⎕SIGNAL(~⎕NEXISTS pckgver)/19
          :Trap 22 ⍝ FILE NAME ERROR may happen if the path does not exist. Most likely "/lib" is the problem...
              r←'/'cutEndAt¨subdirs pckgver,'/lib'
          :Else
              r←'/'cutEndAt¨subdirs pckgver      ⍝ so we just ommit it...
          :EndTrap
         
        ∇

        ∇ r←FullPath
          :Access public
          :If framework≡''
          :AndIf useNS≢⎕NULL
              framework←BestFramework
          :EndIf
          ⎕USING←'System'
          up←Environment.GetFolderPath Environment.SpecialFolder.UserProfile
          pckgs←up,'/.nuget/packages'
          ('global-cache not found (',pckgs,')')⎕SIGNAL(~⎕NEXISTS pckgs)/19
          pckg←pckgs,'/',id
          ('package not found (',pckg,')')⎕SIGNAL(~⎕NEXISTS pckg)/19
          pckgver←pckg,'/',version
          ('package version not found (',pckgver,')')⎕SIGNAL(~⎕NEXISTS pckgver)/19
          ⍝ r←⊃⎕NINFO pckgver,'/lib/',framework,'/',id,'.dll'
          r←pckgver,'/',((useNS≢⎕NULL)/'lib/',framework,'/'),(id,'.dll'){⍵≡'':⍺ ⋄ ⍵}myDLL   ⍝ BAAS: use myDLL if defined...
         
        ∇

        ∇ r←path
          :Access public
          r←'/',id,'/',version,'/lib/'
        ∇

        ∇ r←addPkgStr
          :Access public
          r←id,' --version ',version
        ∇
        startswith← { ⊃¨(⊂⍺){ ⍺≡(≢⍺)↑⍵}¨,⊆⍵}
        sort1←{(1⊃⍒⍵)⌷⍵}

        ∇ r←BestFramework;fws;std;preferred
          :Access public
         
          fws←Frameworks
          dnv←GetDOTNETVersion
          :Select 1⊃dnv
          :Case 0
              'No .NET environment!'⎕SIGNAL 11
          :Case 1   ⍝ framework
              preferred←'netstandard'
          :Case 2    ⍝ NET Core
          ⍝ Bjorn, I'm not sure what we need (or want)  to support...
              :If 6≤3⊃dnv
                  preferred←'net6.0'
              :ElseIf 5≤nv
                  preferred←'net5.0'
              :EndIf
          :EndSelect
          std←sort1 preferred{(⍺ startswith ⍵)/⍵}fws
          r←⊃std
        ∇

        ∇ r←BestVersion
          :Access Public
          r←⊃sort1 Versions
        ∇

        ∇ R←GetDOTNETVersion;vers;⎕IO;⎕USING
⍝ borrowed from Spice.dyalog (used in ]TOOLS.Version etc.)
⍝ R[1] = 0/1/2: 0=nothing, 1=.net Framework, 2=NET CORE
⍝ R[2] = Version (text-vector)
⍝ R[3] = Version (identifiable x.y within [2] in numerical form)
⍝ R[4] = Textual description of the framework
          ⎕IO←1
          R←0 '' 0 ''
          :If (82=⎕DR' ')∨'AIX'≡3↑⊃'.'⎕WG'APLVersion' ⋄ →0 ⋄ :EndIf
          :Trap 0
              ⎕USING←'System' ''
              vers←System.Environment.Version
              R[2]←⊂⍕vers
              R[3]←vers.(Major+0.1×Minor)
              :If 4=⌊R[3]   ⍝ a 4 indicates .net Framework!
                  R[1]←1
                  :If (⍕vers)≡'4.0.30319.42000'   ⍝ .NET 4.6 and higher!
                      R[4]←⊂Runtime.InteropServices.RuntimeInformation.FrameworkDescription
                  :ElseIf (10↑⍕vers)≡'4.0.30319.' ⍝ .NET 4, 4.5, 4.5.1, 4.5.2
                      R[4]←⊂'.NET Framework ',2⊃R  ⍝ JD: good enough?  Otherwise I may need to dig into the registry according to https://docs.microsoft.com/de-de/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed?view=netframework-4.8
                  :EndIf
              :ElseIf 3.1=R[3]  ⍝ .NET CORE
              :OrIf 4<R[3]
                  R[1]←2
                  ⎕USING←'System,System.Runtime.InteropServices.RuntimeInformation'
                  R[4]←⊂Runtime.InteropServices.RuntimeInformation.FrameworkDescription
              :EndIf
          :Else
      ⍝ bad luck, go with the defaults
          :EndTrap
        ∇

    :EndClass

    :Class Project
    :using System
        :field public Name
        :field public Packages
        :Field packagesPath
        :field dotnetCore
        :field dotnetver
        :field projectDir
        :field public Quiet←0   ⍝ print out stuff into session (or not...)

        ∇ make
          :Access public
          :Implements constructor
          makeN ⍬
        ∇

        ∇ makeN argname
          :Access public
          :Implements constructor
          projectDir←⍬
          Packages←⍬
          Name←argname
          packagesPath←(Environment.GetFolderPath Environment.SpecialFolder.UserProfile),'/.nuget/packages'
          dotnetCore←'mscorlib'{⍺≢(≢⍺)↑⍵}Environment.Version.GetType.Assembly.ToString
          dotnetver←⊃('netstandard2.1' 'net45')[(1+'mscorlib'{⍺≡(≢⍺)↑⍵}Environment.Version.GetType.Assembly.ToString)]
        ∇

        ∇ Add p
          :Access public
          Packages,←p
        ∇

        ∇ r←Lookfor p;packageLoc
          packageLoc←packagesPath,p.path,dotnetver
          :If ⎕NEXISTS packageLoc
         
              r←packageLoc,'/',p.id,'.dll'
          :Else
              ∘∘∘
          :EndIf
         
        ∇

        ∇ r←Using;u;ns
          :Access public
         
          u←⍬
          :For p :In Packages
          ⍝ BAAS: added this :if with useNS
              :If 0<≢p.useNS
                  :If p.useNS≢⎕NULL
                      :For ns :In ⊆p.useNS
                          u,←⊂ns,',',p.FullPath
                      :EndFor
                  :EndIf
              :Else
                  u,←⊂p.(id,',',FullPath)
              :EndIf
              ⍝ ENDBAAS
          :EndFor
          r←u
        ∇

        ∇ r←Restore
          :Access Public
          r←CreateDotnetProject
          Quiet{~⍺:↑⍵}⎕CMD'dotnet restore ',r
        ∇

        ∇ r←CreateDotnetProject;path;p
          :If projectDir≡⍬
              ⎕USING,←⊂',System.Runtime.dll'
              path←System.IO.Path.GetTempPath
              projectDir←path,Name
              :If ~⎕NEXISTS projectDir
                  Quiet{~⍺:↑⍵}⎕CMD'mkdir ',projectDir
              :EndIf
          :EndIf
          r←projectDir
          Quiet{~⍺:↑⍵}⎕CMD'dotnet new classlib -o ',projectDir
         
          :For p :In Packages
              Quiet{~⍺:↑⍵}⎕CMD'dotnet add ',projectDir,' package ',p.addPkgStr
          :EndFor
        ∇



    :EndClass
    ∇ r←ScanPckgs dir;sd;ver;zz;trimEndAt;subdirs
      cutEndAt←{(1-(⌽⍵)⍳⍺)↑⍵}
      subdirs←{(n t)←0 1(⎕NINFO⍠1)⍵,'/*' ⋄ (t=1)/n}
      zz←⍬
      :For sd :In subdirs dir
          :For ver :In subdirs sd
              :If ⎕NEXISTS ver,'/lib'
                  zz,←'/'cutEndAt¨subdirs ver,'/lib'
              :EndIf
          :EndFor
      :EndFor
      r←∪zz
    ∇

    ∇ r←SampleNE
     
      pckgs←0 2⍴⍬
      pckgs⍪←'NETCore.Encrypt' '2.0.9'
     
      ne←⎕NEW Project'NE'
     
      :For p :In ↓pckgs
          ne.Add ⎕NEW Package p
      :EndFor
     
      ne.Restore
      ⎕USING←'System' 'System.Reflection'
      ⍪AppDomain.CurrentDomain.GetAssemblies
     
      ⎕USING←(⊂'System'),(ne.Using)
      ⍪AppDomain.CurrentDomain.GetAssemblies
     
     
      EncryptProvider.Sha256⊂'Hello'
    ∇

    ∇ r←SampleJWT;pckgs;jwt;p
      pckgs←0 2⍴⍬
      pckgs⍪←'System.IdentityModel.Tokens.Jwt' '6.8.0'
     
      jwt←⎕NEW Project'JWT'
     
      :For p :In ↓pckgs
          jwt.Add ⎕NEW Package p
      :EndFor
     
      jwt.Restore
     
      ⎕USING←(⊂'System'),(jwt.Using)
     
      EncryptProvider.Sha256⊂'Hello'
     
    ∇
    ∇ r←SampleMailKit;pckgs;jwt;p;mkt
      Env←{+2 ⎕NQ'.' 'GetEnvironment'⍵}
      pckgs←0 2⍴⍬
      pckgs⍪←'MimeKit' '3.5.0'
      pckgs⍪←'MailKit' '3.5.0'
     
      mkt←⎕NEW Project'SampleMailKit'
     
      :For p :In ↓pckgs
          mkt.Add ⎕NEW Package p
      :EndFor
     
      mkt.Restore
     
      ⎕USING←(⊂'System'),(mkt.Using)
      client←⎕NEW Pop3Client
      client.Connect(Env'CITA_SMTP_SERVER')(110)(0)
      client.Authenticate(Env'CITA_SMTP_USER')(Env'CITA_SMTP_PASSWORD')
      ⎕←client.Count
      ∘∘∘
    ∇


    ∇ r←SampleSelenium;pckgs;p;Selenium;pth;drv;drvs;nam;s2bs;av
      av←'-'~⍨⎕C 1⊃'.'⎕WG'aplversion'
      ⍝ determine path for ChromeDriver:
      ⍝ it is stored under package ("selenium.webdriver.chromedriver") and version ("98.0.4758.8000")
      ⍝ in subfolders of "\driver\" per os (win32|linux64|macos64) as file "chromedriver.exe"
      chromedriver←'driver/',(('dows' '64'⎕R'' '32')av),'/chromedriver',('w'=1⊃av)/'.exe'
      pckgs←0 4⍴⍬
      pckgs⍪←'Selenium.WebDriver' '4.1.0'('OpenQA' 'OpenQA.Selenium' 'OpenQA.Selenium.Chrome')'WebDriver.dll'
      pckgs⍪←'Selenium.WebDriver.ChromeDriver' '90.0'⎕NULL chromedriver
      pckgs⍪←'Newtonsoft.Json' '12.0.1' '' ''
    ⍝ ⎕NULL in [3] will add & install the package, but not add it to ⎕USING
    ⍝ BUT we can query its location with FullPath
      Selenium←⎕NEW Project'Selenium'
     
      {Selenium.Add ⎕NEW Package ⍵}¨↓pckgs
     
      Selenium.Restore
      :If 'w'≡1⊃av
          s2bs←{'\'@('/'∘=)⍵}    ⍝ slash to backslash
      :Else
          s2bs←{'/'@('\'∘=)⍵}    ⍝ and backslash to slash everywhere else... ;)
      :EndIf
     
      ⎕USING←(⊂'System'),(s2bs¨Selenium.Using)
     
      pth←s2bs(2⊃Selenium.Packages).FullPath
      nam←∊1↓⎕NPARTS pth
      pth←1⊃⎕NPARTS pth
      drvs←ChromeDriverService.CreateDefaultService(pth)(nam)    ⍝ DriverService
      drv←⎕NEW ChromeDriver drvs
      drv.Url←'https://selenium.dev'
      ∘∘∘
      drv.Quit ⍬
     
    ∇





    ∇ NuGetPackageHandler(obj args);p;⎕USING
      ⎕←obj
      ⎕←args
      ⎕USING←'System' 'System.Reflection'
      split←{1↓¨(⍺=⍺,⍵)⊂⍺,⍵}
      trimEndAt←{(-(⌽⍵)⍳⍺)↓⍵}
      p←⎕NEW Package args.Name
     
      p.version←⊃{(⍒⍵)⌷⍵}p.Versions
      p.framework←⊃p.Frameworks
      ⎕←'Loading:',p.FullPath
      Assembly.LoadFrom⊂p.FullPath
    ∇


    ∇ Hook
      ⎕USING←'System'
     
      cd←AppDomain.CurrentDomain
      cd.onAssemblyResolve←'#.NugetConsum.NuGetPackageHandler'
    ∇

:EndNamespace
