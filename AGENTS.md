# Google Cloud Foundation Fabric (FAST) - Nimeämiskäytännöt

Tämä repositorio noudattaa kaikissa vaiheissa virallisia Google Cloud Foundation Fabric (FAST) -resurssinimeämisstandardeja. Noudata näitä ohjeita kaikessa luotavassa ja muokattavassa Terraform- ja GCP-koodissa.

## 1. Perusrakenne
- **Ei kovaakoodattuja alkuosia**: Älä koskaan kovaakoodaa resurssien nimien alkuosioita (kuten `prod-`, `dev-`, `fast-`).
- **Keskitetyt muuttujat**: Kaikkien resurssien nimien tulee perustua keskitettyyn `${var.prefix}`-muuttujaan (oletus: `"fast"`) ja ympäristötunnisteeseen `${var.environment}` / `${local.environment}` (esim. `"prod"` tai `"dev"`).
- **Yleinen nimeämiskaava**: `${var.prefix}-${var.environment}-<resurssi>`

## 2. Vaihekohtaiset (Stage) nimeämisstandardit

### Stage 0: Bootstrap (`0-bootstrap/`)
- **Seed-projekti**: `${var.prefix}-prod-iac-0` (projektin ID leikataan tarvittaessa 30 merkkiin satunnaissuffiksin kanssa: `substr("${var.prefix}-prod-iac-0-${random_string.project_suffix.result}", 0, 30)`)
- **Automaation palvelutilit (Service Accounts)**:
  - Resource Management: `${var.prefix}-stage1-resman`
  - Networking: `${var.prefix}-stage2-net`
  - Security: `${var.prefix}-stage2-sec`
  - Project Factory / Workloads: `${var.prefix}-stage2-pf`
- **Etätilasäiliöt (GCS Buckets)**: `${var.prefix}-state-<vaihe>-<suffix>`

### Stage 1: Resource Management (`1-resman/`)
- **GCP-pääkansiot (Folders)**:
  - `${var.prefix}-networking`
  - `${var.prefix}-security`
  - `${var.prefix}-common`
  - `${var.prefix}-workloads`
- **Ympäristökansiot**:
  - `${var.prefix}-workloads-dev`
  - `${var.prefix}-workloads-prod`

### Stage 2: Networking & Security (`2-networking/`, `2-security/`)
- **Shared VPC -isäntäprojekti**: `${var.prefix}-${var.environment}-net-host`
- **Shared VPC -verkko**: `${var.prefix}-${var.environment}-shared-vpc`
- **Aliverkot (Subnets)**: `${var.prefix}-${var.environment}-<aliverkon_nimi>` (ei kovakoodattuja `prod-` etuliitteitä muuttujissa)
- **Security-projekti**: `${var.prefix}-${var.environment}-sec-core`
- **KMS-avainrenkaat**: `${var.prefix}-${var.environment}-kr-${var.region}` (alueittain)
- **KMS-avaimet**: `${var.prefix}-${var.environment}-key-<tarkoitus>`
- **Secret Manager -salaisuudet**: `${var.prefix}-${var.environment}-<secret_id>`
- **Certificate Authority Service**: `${var.prefix}-${var.environment}-ca-pool`

### Stage 3: Workloads (`3-workloads/`)
- **Sovellusprojekti**: `${var.prefix}-${var.environment}-app`
- **Sovelluspalvelut ja liitännäiset**: `${var.prefix}-${var.environment}-<palvelun_nimi>`
  - Cloud Run -palvelu: `${var.prefix}-${local.environment}-${local.app_name}`
  - Cloud Run -palvelutili: `substr("${var.prefix}-${local.environment}-${local.app_name}-sa", 0, 30)`
  - Cloud Armor: `${var.prefix}-${local.environment}-armor` (tai `try(local.armor_yaml.security_policy.name, "${var.prefix}-${local.environment}-armor")`)
  - Serverless NEG: `${var.prefix}-${local.environment}-${local.app_name}-neg`
  - Backend Service: `${var.prefix}-${local.environment}-${local.app_name}-backend`
  - URL Map: `${var.prefix}-${local.environment}-${local.app_name}-url-map`
  - IP-osoite: `${var.prefix}-${local.environment}-${local.app_name}-lb-ip`
  - HTTP Proxy: `${var.prefix}-${local.environment}-${local.app_name}-http-proxy`
  - HTTP Forwarding Rule: `${var.prefix}-${local.environment}-${local.app_name}-http-rule`
  - SSL-sertifikaatti: `${var.prefix}-${local.environment}-${local.app_name}-cert`
  - HTTPS Proxy: `${var.prefix}-${local.environment}-${local.app_name}-https-proxy`
  - HTTPS Forwarding Rule: `${var.prefix}-${local.environment}-${local.app_name}-https-rule`

## 3. Toteutustapa ja YAML-integraatio
- Muodosta nimet dynaamisesti HCL-koodissa interpolaatiolla tai local-muuttujilla.
- Jos nimeä ei ole määritelty syötteessä (esim. YAML-konfiguraatiossa), käytä aina `try()`-funktiota ja varasijana virallista FAST-nimeämiskaavaa:
  ```hcl
  security_policy_name = try(local.armor_yaml.security_policy.name, null) != null ? local.armor_yaml.security_policy.name : "${var.prefix}-${local.environment}-armor"
  ```
