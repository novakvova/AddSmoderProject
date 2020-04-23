FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base

#install application for get HW info
RUN apt-get update
RUN apt-get install -y mc
RUN apt-get install -y curl
RUN apt-get install -y hwinfo
RUN apt-get install -y busybox
RUN apt-get install -y iputils-ping

#National Language (locale) data
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT false
RUN apt-get install -y locales
RUN locale-gen uk_UA.UTF-8
ENV LC_ALL uk_UA.UTF-8
ENV LANG uk_UA.UTF-8

WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src
COPY ["SiteApi/SiteApi.csproj", "SiteApi/"]
RUN dotnet restore "SiteApi/SiteApi.csproj"
COPY . .
WORKDIR "/src/SiteApi"
RUN dotnet build "SiteApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "SiteApi.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SiteApi.dll"]