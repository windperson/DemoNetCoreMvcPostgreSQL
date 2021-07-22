# ASP.NET Core MVC PostgreSQL DB demo

1. Spin up DB by invoking command line in Powershell, switching to the `docker_postgis` folder, then invoke:
  
    ```powershell
    ./dev_start.ps1 -compose_proj DemoNetCoreMvc -gis_db demo_db -gis_port 5433
    ```
  
2. Run `dotnet run` inside the `DemoNetCoreMvcPostgreSQL` folder.
