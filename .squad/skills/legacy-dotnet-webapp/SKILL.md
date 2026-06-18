# Legacy .NET WebApp Pattern (Web Forms on Mono)

Confidence: high
Last validated: 2026-05-14

## Pattern

Build era-appropriate .NET webapps using ASP.NET Web Forms running on Mono 6.12 with XSP4 web host. Use standard server controls, SqlDataSource, and ViewState-heavy state management to maintain 2005-2015 authenticity.

## When to Use

- Building legacy demoware requiring ASP.NET Web Forms applications
- Supporting demonstration of modernization from Web Forms to contemporary .NET patterns
- Running on Linux with Mono 6.12 (Windows IIS not required)
- Database: SQL Server via ADO.NET/SqlCommand or EF6

## Implementation

### Web Forms Application Structure

```
ZavaLoanPortal/
├── Default.aspx
├── Default.aspx.cs
├── Site.Master
├── Web.config
├── Dockerfile
└── ZavaLoanPortal.csproj
```

### Server Controls with ViewState

```asp
<%@ Page MasterPageFile="~/Site.Master" %>

<asp:GridView ID="gvAccounts" runat="server" AutoGenerateColumns="false" 
    OnRowCommand="gvAccounts_RowCommand">
    <Columns>
        <asp:BoundField DataField="AccountID" HeaderText="Account" />
        <asp:BoundField DataField="Balance" HeaderText="Balance" DataFormatString="{0:C}" />
        <asp:ButtonField CommandName="ViewDetails" ButtonType="Link" Text="Details" />
    </Columns>
</asp:GridView>

<asp:SqlDataSource ID="sqlAccounts" runat="server"
    ConnectionString="<%$ ConnectionStrings:DefaultConnection %>"
    SelectCommand="SELECT AccountID, Balance FROM Accounts WHERE CustomerID = @CustomerID">
    <SelectParameters>
        <asp:ControlParameter ControlID="ddlCustomer" PropertyName="SelectedValue" Name="CustomerID" />
    </SelectParameters>
</asp:SqlDataSource>
```

### Code-Behind

```csharp
public partial class Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            gvAccounts.DataSourceID = "sqlAccounts";
            gvAccounts.DataBind();
        }
    }

    protected void gvAccounts_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "ViewDetails")
        {
            int accountId = int.Parse(gvAccounts.DataKeys[e.NewSelectedIndex].Value);
            Response.Redirect("AccountDetail.aspx?id=" + accountId);
        }
    }
}
```

### Web.config

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <connectionStrings>
    <add name="DefaultConnection" connectionString="Server=sqlserver;Database=ZavaBankDB;User=zavaapp;Password=ZavaBank2024!" 
         providerName="System.Data.SqlClient" />
  </connectionStrings>
  <appSettings>
    <add key="RABBITMQ_HOST" value="rabbitmq" />
    <add key="RABBITMQ_PORT" value="5672" />
  </appSettings>
  <system.web>
    <compilation debug="false" targetFramework="4.8" />
    <httpRuntime targetFramework="4.8" />
    <authentication mode="Forms">
      <forms name=".ZAVAAUTH" loginUrl="Login.aspx" defaultUrl="Default.aspx" timeout="30" />
    </authentication>
    <machineKey validationKey="F94...[64 hex chars]..." decryptionKey="A94...[64 hex chars]..." validation="SHA1" decryption="AES" />
  </system.web>
</configuration>
```

### Master Page for Layout

```asp
<%@ Master Language="C#" AutoEventWireup="true" CodeBehind="Site.master.cs" Inherits="ZavaLoanPortal.Site" %>
<!DOCTYPE html>
<html>
<head>
    <title>Zava Bank — <asp:ContentPlaceHolder ID="Title" runat="server" /></title>
    <style>
        body { font-family: Arial; background: #f0f0f0; }
        table { border-collapse: collapse; border: 1px solid #ccc; }
        th, td { padding: 8px; border: 1px solid #ccc; text-align: left; }
    </style>
</head>
<body>
    <h1>Zava Bank Portal</h1>
    <asp:ContentPlaceHolder ID="Content" runat="server" />
</body>
</html>
```

### .csproj (Legacy Format)

```xml
<Project ToolsVersion="4.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <TargetFrameworkVersion>v4.8</TargetFrameworkVersion>
    <OutputPath>bin\</OutputPath>
  </PropertyGroup>
  <ItemGroup>
    <Reference Include="System" />
    <Reference Include="System.Web" />
    <Reference Include="System.Data" />
  </ItemGroup>
  <ItemGroup>
    <None Include="packages.config" />
  </ItemGroup>
</Project>
```

### packages.config

```xml
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="EntityFramework" version="6.4.4" targetFramework="net48" />
  <package id="log4net" version="2.0.12" targetFramework="net48" />
</packages>
```

### Dockerfile

```dockerfile
FROM mono:6.12

WORKDIR /app

# Copy pre-built publish folder
COPY publish/ /app/

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=15s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Environment variables
ENV DB_HOST=sqlserver \
    DB_PORT=1433 \
    DB_USER=zavaapp \
    DB_PASSWORD=ZavaBank2024!

# Run XSP4
ENTRYPOINT ["xsp4", "--port", "8080", "--address", "0.0.0.0"]
```

## Gotchas

1. **No exotic third-party controls:** Mono supports standard ASP.NET server controls (GridView, FormView, Repeater, TextBox, Button) but not vendor-specific grids or date-pickers. Verify Mono compatibility before using external controls.

2. **ViewState serialization:** Large ViewState can cause performance issues. Keep pages simple to minimize serialized state.

3. **Windows-specific APIs:** Avoid Registry access, COM interop, or Windows authentication (NTLM). Use SQL Server authentication instead.

4. **Master page machineKey:** Ensure all Web Forms apps share the same `machineKey` in web.config for cookie decryption across FormsAuth trust boundaries.

5. **File paths:** Use forward slashes in `~/` path prefixes or URL construction; avoid hardcoded C:\ paths.

6. **SQL Server connectivity:** Mono's SQL Server support via System.Data.SqlClient is reliable, but ensure proper connection string syntax and firewall rules for Docker networks.
