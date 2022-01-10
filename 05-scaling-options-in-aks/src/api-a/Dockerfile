#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:5.0-buster-slim AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:5.0-buster-slim AS build
WORKDIR /src
COPY ["api-a/api-a.csproj", "api-a/"]
RUN dotnet restore "api-a/api-a.csproj"
COPY . .
WORKDIR "/src/api-a"
RUN dotnet build "api-a.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "api-a.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "api-a.dll"]