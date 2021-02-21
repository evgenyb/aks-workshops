#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:5.0-buster-slim AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:5.0-buster-slim AS build
WORKDIR /src
COPY ["api-b/api-b.csproj", "api-b/"]
RUN dotnet restore "api-b/api-b.csproj"
COPY . .
WORKDIR "/src/api-b"
RUN dotnet build "api-b.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "api-b.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "api-b.dll"]