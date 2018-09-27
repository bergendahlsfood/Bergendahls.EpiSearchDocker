FROM microsoft/dotnet-framework:4.7.1-sdk as build
WORKDIR /app
COPY . .
RUN nuget.exe restore Episerver.Search.sln
RUN msbuild.exe Episerver.Search.sln \
	/p:Configuration=Release \
	/p:PublishProfile=FolderProfile \
	/p:DeployOnBuild=true

FROM microsoft/aspnet:4.7.1
WORKDIR /app
RUN mkdir -p /inetpub/wwwroot/App_Data/Index
RUN Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
RUN Install-Module -Name NTFSSecurity -Force
RUN Add-NTFSAccess -Path '/inetpub/wwwroot' -Account BUILTIN\IIS_IUSRS -AccessRights FullControl

COPY --from=build /app/publish /inetpub/wwwroot
COPY --from=build /app/Startup.ps1 /app/Startup.ps1
ENTRYPOINT ["powershell.exe", "/app/Startup.ps1"]
