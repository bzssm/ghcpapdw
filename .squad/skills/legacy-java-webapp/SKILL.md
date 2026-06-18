# Legacy Java WebApp Pattern (Struts 1.x/2.x + Servlet)

Confidence: high
Last validated: 2026-05-14

## Pattern

Build era-appropriate Java webapps using Struts 1.x or 2.x with JSP views, raw JDBC database access, and Gradle build system. No modern frameworks (Spring, Spring Boot, Hibernate) to maintain 2005-2015 authenticity.

## When to Use

- Building legacy demoware requiring Struts 1.x or 2.x applications
- Supporting demonstration of modernization from legacy to contemporary Java patterns
- Requiring raw JDBC data access with PreparedStatement
- Running on Tomcat 9 with JRE 8 or newer

## Implementation

### Struts 1.x (Stateless action-based framework)

**Configuration:** `src/main/resources/struts-config.xml`
```xml
<struts-config>
  <form-beans>
    <form-bean name="paymentForm" type="com.zava.forms.PaymentForm"/>
  </form-beans>
  <action-mappings>
    <action path="/payment" type="com.zava.actions.PaymentAction" name="paymentForm" input="/payment.jsp">
      <forward name="success" path="/success.jsp"/>
    </action>
  </action-mappings>
</struts-config>
```

### Struts 2.x (Annotation-based, OGNL expressions)

**Configuration:** `src/main/resources/struts.xml`
```xml
<struts>
  <package name="default" extends="struts-default">
    <action name="fraudReport" class="com.zava.actions.FraudReportAction">
      <result name="success">/fraud-report.jsp</result>
    </action>
  </package>
</struts>
```

### Raw JDBC Data Access

```java
// No Hibernate; use raw JDBC with Connection pooling (Commons DBCP or Tomcat JDBC)
public class PaymentDAO {
    private DataSource dataSource; // Injected via JNDI or constructor
    
    public void savePayment(Payment p) throws SQLException {
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "INSERT INTO Payments (account_id, amount, status, created_date) VALUES (?, ?, ?, ?)")) {
            stmt.setInt(1, p.getAccountId());
            stmt.setBigDecimal(2, p.getAmount());
            stmt.setString(3, "PENDING");
            stmt.setTimestamp(4, new Timestamp(System.currentTimeMillis()));
            stmt.executeUpdate();
        }
    }
}
```

### Gradle Build

```gradle
plugins {
    id 'java'
    id 'war'
}

dependencies {
    compileOnly 'org.apache.struts:struts-core:1.3.10'
    compileOnly 'javax.servlet:servlet-api:2.5'
    
    implementation 'commons-dbcp:commons-dbcp:1.4'
    implementation 'com.microsoft.sqlserver:mssql-jdbc:9.2.1.jre8'
    implementation 'org.apache.commons:commons-logging:1.2'
    
    testImplementation 'junit:junit:4.13.2'
}

war {
    archiveBaseName = 'zavaloan-origination'
}
```

### JSP Views

```jsp
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<h2>Payment History</h2>
<table>
  <c:forEach var="payment" items="${payments}">
    <tr>
      <td><bean:write name="payment" property="id"/></td>
      <td><bean:write name="payment" property="amount"/></td>
    </tr>
  </c:forEach>
</table>
```

### Docker Deployment

```dockerfile
FROM tomcat:9-jre8

COPY target/*.war $CATALINA_HOME/webapps/

ENV DB_HOST=sqlserver \
    DB_PORT=1433 \
    JDBC_URL=jdbc:sqlserver://${DB_HOST}:${DB_PORT};database=ZavaBankDB
```

## Gotchas

1. **Struts 1.x vs 2.x:** Struts 1.x is legacy (unmaintained but stable); Struts 2.x is newer (2005-2012 era) with OGNL expressions. Choose based on era and complexity.
2. **JDBC connection pooling:** Don't create new Connection objects per request. Use DataSource with connection pooling (Commons DBCP, Tomcat JDBC Pool).
3. **N+1 queries:** Raw JDBC makes it easy to fall into N+1 queries. Batch fetches into single queries; avoid loading related objects in loops.
4. **JSP taglibs:** Struts taglibs (`<bean:write>`) are verbose compared to modern JSTL, but appropriate for era.
5. **Classpath configuration:** Struts-config.xml must be on classpath; ensure `web.xml` ActionServlet references it correctly.
6. **Transaction management:** No automatic transaction handling; wrap DAO methods in explicit try/catch with connection management.
