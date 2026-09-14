# Identity Engineering Portfolio

Documentation of enterprise identity & access management processes, workflows, and automation opportunities in production environments.

---

# Onboarding Flow - User Provisioning in Technoma/Ueno Bank

## System Overview

### Active Organizations
- **Ueno** (formerly El Comercio)
- **ITTI**

### Legacy Infrastructure (Shared Drives Only)
- **Vision** (legacy, shared drives only, no active nomina)
- **Credicentro** (legacy, shared drives only, no active nomina)
- Each has separate IP ranges, users, passwords, and policies
- Purpose: legacy shared drive access only

### Central Systems (Current State)

- **Identity Provider**: Okta
  - Multiple tenants by nomina (Ueno, ITTI)
  - Central authentication for all systems
  
- **Endpoint Management (Primary)**: JumpCloud
  - Device provisioning and enrollment (Windows + macOS)
  - Device authentication against Okta
  - Application deployment
  - Compliance validation
  
- **Active Directory**: Legacy (Shared Drives Only)
  - Ueno AD, ITTI AD, Vision AD, Credicentro AD
  - **No longer used** for device authentication (migrated to JumpCloud)
  - Still used for shared drive access (being deprecated)
  
- **Security**: Netskope
  - Antivirus + endpoint compliance
  - Deployed via JumpCloud
  - Device compliance validation required before full access
  
- **Applications**: Google Workspace, Salesforce, Bankitti, Jira/Atlassian
  - All accessible via Okta SSO

---

## Step-by-Step Onboarding Process

### Phase 0: Pre-Provisioning (HR + Logical Access)
1. HR submits onboarding request → determines nomina (Ueno or ITTI)
2. Logical Access creates user in corresponding Okta tenant
3. Logical Access creates user in corresponding AD (if shared drive access needed)
4. **Result**: identities provisioned before device setup

### Phase 1: Device Enrollment & Authentication (JumpCloud + Okta + Netskope)

1. Device is pre-enrolled in **JumpCloud**
2. User boots device and sees JumpCloud login screen
3. User enters corporate email + temporary Okta password
4. JumpCloud authenticates against Okta (federated identity)
5. User creates permanent password with **MFA requirement**
6. **Netskope antivirus** activates and validates device compliance
7. JumpCloud confirms device enrollment complete
8. Windows creates local user account
9. Google Chrome auto-configures with Okta SSO
10. Endpoint Verification validates device synchronization
11. **Result**: device authenticated, MFA enabled, Netskope compliant

### Phase 2: Application Access (SSO Verification)

1. Chrome opens with Google Workspace SSO (user already authenticated)
2. Okta dashboard loads with available applications
3. Jira/Atlassian opens automatically via Okta SSO
4. Cloudflare VPN activates with Okta credentials
5. Salesforce, Bankitti appear in Okta dashboard
6. Endpoint Verification validates device compliance
7. **Result**: all applications accessible via Okta SSO

### Phase 3: Shared Drive Access (Legacy Active Directory)

#### Current Workflow (Manual Process)
1. User requests shared drive access → ticket to Logical Access
2. Logical Access grants AD user permissions on shared folder
   - Permission tied to specific legacy AD (Vision, Credicentro, Ueno, ITTI)
   - AD password created (30-day expiry)
3. **Endpoint Support receives notification**
4. Endpoint Support manually adds credentials to Windows Credential Manager:
   - Username: AD user
   - Password: AD temporary password
   - IP: Legacy AD server IP
   - Path: `\\server\shared_folder`
5. User accesses shared drive through Credential Manager
6. **After 30 days**: AD password expires, user loses access
7. **Cycle repeats**: password reset → manual re-entry in Credential Manager

#### Pain Points with Current Workflow
- **Manual process**: every shared drive request requires manual credential entry
- **Password expiration**: 30-day cycle creates recurring manual work every month
- **No automation**: no sync between AD permission grant and credential distribution
- **Legacy complexity**: multiple ADs running for shared drives only
- **Support tickets**: regular password expiration failures create escalations
- **Doesn't scale**: process breaks down with more users or access requests
- **User friction**: users experience access loss every 30 days until Endpoint manually re-adds

---

## Architecture & Data Flow

### Identity Flow Diagram
```
┌─────────────────────────────────────────────────────────────┐
│                    User Onboarding Flow                     │
└─────────────────────────────────────────────────────────────┘

1. HR Request (nomina: Ueno or ITTI)
   ↓
2. Okta Tenant Created (Ueno or ITTI specific)
   ↓
3. JumpCloud Device Enrolled
   ↓
4. User Login to JumpCloud
   ↓
5. JumpCloud ←→ Okta Authentication (Federated)
   ↓
6. Netskope Compliance Check
   ↓
7. MFA Setup (Okta)
   ↓
8. Access Granted → Okta Dashboard
   ↓
9. SSO to Applications (Google, Salesforce, Bankitti, Jira)
   ↓
10. (Optional) Shared Drive Access via Legacy AD
    - Request → Logical Access approval → Endpoint adds to Credential Manager
```

### System Interconnections
```
Okta (Central IdP)
├─ Authenticates JumpCloud device login
├─ Provides MFA
├─ Manages application SSO
└─ Integrates with Netskope for compliance

JumpCloud (MDM)
├─ Enrolls devices (Windows + macOS)
├─ Authenticates against Okta
├─ Deploys Netskope
└─ Manages device compliance

Netskope (Security)
├─ Antivirus + threat protection
├─ Device compliance validation
└─ Deployed via JumpCloud

Google Workspace, Salesforce, Bankitti, Jira
└─ All authenticate via Okta SSO

Legacy AD (Vision, Credicentro, Ueno, ITTI)
└─ Shared drive access only (being deprecated)
   - User/password management (30-day expiry)
   - Separate credentials from Okta
```

---

## Security & Compliance Concepts

- **SSO (Single Sign-On)**: Okta as central identity provider
- **Federated Identity**: JumpCloud + Okta integration (device auth delegates to Okta)
- **MFA (Multi-Factor Authentication)**: Mandatory Okta MFA during device setup
- **Device Compliance**: Netskope enrollment mandatory before full system access
- **Just-In-Time Provisioning**: users/apps created on-demand
- **Legacy Integration**: on-prem AD for shared drives (coexists during transition)
- **Password Policy**: 30-day expiry for legacy AD (pain point to automate)

---

## Historical Context: Absolute Era (2024-2026)

### Background
Eduardo's primary hands-on experience at Technoma/Ueno during 2024-2026 was with **Absolute** as the primary endpoint management tool. Absolute has been the tool for device provisioning, application deployment, and endpoint management.

### Absolute Responsibilities (Historical)
- Executed scripts deployed via Absolute for:
  - Device imaging and provisioning
  - Software installation packages
  - Netskope antivirus deployment
  - JumpCloud enrollment automation (Absolute scripts to prepare for JumpCloud)
  - System configuration and policies
  - Credential mapping for shared drives

### Transition to JumpCloud
- **Timeline**: Absolute is being phased out as JumpCloud becomes primary MDM
- **Current State** (Sep 2026): New devices use JumpCloud directly
- **Historical Value**: Understanding Absolute scripts informs understanding of endpoint management evolution and infrastructure migration patterns

### Learning from Absolute → JumpCloud Migration
This transition is a live case study in:
- How legacy endpoint management tools are replaced
- Why consolidation (one MDM vs multiple tools) matters operationally
- Script conversion and automation (Absolute scripts → JumpCloud/PowerShell equivalents)
- Zero-downtime infrastructure transitions
- Identifying what's critical vs. what can be deprecated

---

## Opportunities for Automation (PowerShell Era)

### Opportunity 1: Automate Shared Drive Access Provisioning
**Current State**: Manual Credential Manager entry for legacy AD shared drives

**Current Workflow Issues**:
- User requests access → Logical Access approves → Endpoint manually types credentials into Credential Manager
- Each request: ~5 minutes of manual work
- High error rate (typos in passwords, wrong AD server IP)
- No audit trail of who added what when

**Proposed Solution**: PowerShell Script
```
Trigger: When Logical Access grants AD permission in ticketing system

Script Actions:
1. Detect permission grant event
2. Extract: AD server, username, temporary password, share path
3. Locate user's device (via JumpCloud API)
4. Encrypt password
5. Add to Windows Credential Manager via JumpCloud remote execution
6. Send notification to user: "Drive access ready"
7. Log action: timestamp, user, drive, operator
```

**Impact**:
- Eliminate manual step (reduce provisioning time from hours to minutes)
- Reduce errors (no typos, automation ensures consistency)
- Create audit trail (security + compliance)
- Scalable (works for 1 user or 100 users)

### Opportunity 2: Automate AD Password Rotation (30-Day Cycle)
**Current State**: 30-day AD password expiry creates recurring manual reset cycle

**Current Workflow Issues**:
- Every 30 days: AD password expires
- User loses access until Endpoint notices and resets password
- Endpoint has to:
  - Reset password in AD
  - Update password in Credential Manager
  - Notify user
- Recurring manual work for every user, every month

**Proposed Solution**: PowerShell Script
```
Trigger: Daily check at 6 AM

Script Actions:
1. Query all legacy AD servers (Vision, Credicentro, Ueno, ITTI)
2. Identify passwords expiring in next 7 days
3. Reset password 7 days BEFORE expiry (not after)
4. Auto-update Credential Manager on user's device
5. Send notification: "Drive access password updated automatically"
6. Generate compliance report (audit trail)
7. Log action: timestamp, user, AD, new password hash (hashed, not plaintext)
```

**Impact**:
- Eliminate password expiration failures (proactive, not reactive)
- Reduce recurring manual work (automates entire 30-day cycle)
- Improve user experience (no interruption to shared drive access)
- Better audit trail (automated logs)
- **Estimated time saved**: ~2 hours/week per Endpoint Support person

### Opportunity 3: Migrate Legacy AD Shared Drives to JumpCloud (Long-term)
**Current State**: Multiple on-prem ADs running for shared drives only

**Proposed Solution** (12-18 month roadmap):
- Migrate Vision, Credicentro shared drives to Azure Files + JumpCloud groups
- Users access shared drives via JumpCloud group membership (not separate AD passwords)
- Shared drive access becomes part of Okta/JumpCloud workflow (not legacy AD)
- Netskope integrates with JumpCloud for shared drive compliance

**Benefits**:
- Eliminate separate AD password expiry (30-day pain goes away)
- Single identity provider (Okta) for everything
- Better compliance posture
- Eliminates 4 legacy AD systems

**Timeline**: Post-Absolute deprecation (2027+)

### Opportunity 4: Document Current Automation Opportunities
**Proposed Solution**:
- Audit all current manual shared drive processes
- Document step-by-step workflow in GitHub (like this document)
- Identify exact pain points (time, errors, security risks)
- Create PowerShell proof-of-concepts
- Test in non-production before deployment
- Build runbook for rollout

**Impact**:
- Clear project plan for automation
- Baseline to measure improvement
- Reference for future similar automations

---

## Next Steps & Roadmap

### Immediate (Sep-Oct 2026)
- [ ] Document all current manual shared drive processes
- [ ] Identify exact pain points (30-day cycle, credential entry errors, audit gaps)
- [ ] Create first PowerShell script: AD password expiration automation
- [ ] Test in non-production environment

### Medium-term (Nov-Dec 2026)
- [ ] Build PowerShell script: automated shared drive access provisioning
- [ ] Integrate with Logical Access ticketing system
- [ ] Create documentation + runbook for both scripts
- [ ] Test end-to-end workflow with sample users

### Long-term (2027+)
- [ ] Plan and execute legacy AD → JumpCloud migration
- [ ] Consolidate Vision, Credicentro shared drives to Azure Files
- [ ] Eliminate separate AD password expiry (full Okta/JumpCloud workflow)
- [ ] Archive Absolute documentation (historical reference only)

---

## Skills Developed / Required

### Current (Sep 2026)
- ✅ Active Directory management (user creation, permissions, groups)
- ✅ JumpCloud device enrollment and troubleshooting
- ✅ Okta integration with devices (federated auth, MFA)
- ✅ Netskope deployment and compliance validation
- ✅ Legacy infrastructure management (multiple ADs, shared drives)
- ✅ Ticketing and documentation (Jira)

### To Develop (Oct 2026 - Apr 2027)
- 🔄 PowerShell scripting (current: basic, target: intermediate-advanced)
- 🔄 JumpCloud API integration (device management, remote execution)
- 🔄 Windows Credential Manager automation
- 🔄 Azure Files + JumpCloud integration (future migration)
- 🔄 Okta API integration (for compliance/audit automation)

### Long-term (Professional Goals)
- Identity & Access Management (IAM) specialization
- Endpoint Management expertise (JumpCloud, cloud MDM)
- Infrastructure migration experience (Absolute → JumpCloud + AD → Azure)
- Automation & DevOps practices (PowerShell, scripting, CI/CD)
- Security compliance (Netskope, device posture, audit trails)

---

## References & Resources

### Internal (Technoma/Ueno)
- Absolute scripts (legacy documentation, historical reference)
- JumpCloud console and API documentation
- Okta tenant configuration
- Active Directory schemas (Vision, Credicentro, Ueno, ITTI)
- Netskope integration with JumpCloud

### External
- [JumpCloud Documentation](https://jumpcloud.com/resources/documentation)
- [Okta Developer Documentation](https://developer.okta.com/)
- [Microsoft PowerShell Documentation](https://docs.microsoft.com/powershell/)
- [Azure Files & JumpCloud Integration](https://docs.microsoft.com/azure/storage/files/)
- [Netskope Integration Guides](https://support.netskope.com/)

---

## Contact & Questions

For questions about this documentation or identity/access management at Technoma/Ueno:
- **LinkedIn**: [eduardoespinola](https://linkedin.com/in/eduardoespinola)
- **GitHub**: [eduardoespinola](https://github.com/eduardoespinola)

---

*Last Updated: September 2026*
*Status: Living Document (updated as infrastructure evolves)*
