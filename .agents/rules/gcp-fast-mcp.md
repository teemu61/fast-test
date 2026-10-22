# Google Cloud Fabric FAST & MCP -toimintasäännöt

Tämä ohjeistus määrittelee MCP (Model Context Protocol) -työkalujen ja Google Cloud Foundation Fabric (FAST) -käytäntöjen soveltamisen tässä repositoriossa. Noudata näitä periaatteita aina, kun luot tai muokkaat Terraform-koodia, FAST-vaiheita (stageja) tai data-driven YAML-tehtaita (factories).

## 1. Skeemojen varmistus (`terraform` MCP)
- **Ajantasaiset provider-skeemat**: Tarkista aina `google`- ja `google-beta`-providerien ajantasaiset resurssi- ja attribuuttiskeemat `terraform` MCP -palvelimelta ennen uuden Terraform-koodin kirjoittamista tai resurssiblokkien muokkaamista.
- **Ei attribuuttien arvaamista**: Älä koskaan arvaa argumentteja, attribuuttien nimiä tai lohkorakenteita ulkomuistista. Varmista tyyppimääritykset ja pakolliset kentät skeemasta.

## 2. Arkkitehtuuri ja rajoitteet (`google-developer-knowledge` & `gemini-cloud-assist` MCP)
- **Virallinen dokumentaatio ja suositukset**: Kun suunnittelet tai muokkaat:
  - Verkkoarkkitehtuuria (esim. Shared VPC, Hub-and-Spoke, NCC / Network Connectivity Center, Cloud HA VPN, Cloud Interconnect)
  - IAM-rooleja, Least Privilege -oikeuksia ja palvelutilejä
  - VPC Service Controls (VPC-SC) -perimetrejä, access level -sääntöjä ja ingress/egress-politiikkoja
  hae ensin virallinen dokumentaatio, arkkitehtuurikuvaukset ja Googlen parhaat käytännöt `google-developer-knowledge`- ja `gemini-cloud-assist` -MCP-palvelimilta.
- **Rajoitteiden ja kiintiöiden ennakointi**: Varmista GCP-palvelukohtaiset rajoitukset ja riippuvuudet ennen arkkitehtuuripäätöksiä.

## 3. Ympäristön tilan tarkistus (`gcloud` MCP)
- **Vain lukuoikeudet (Read-Only)**: Käytä `gcloud` MCP -palvelinta ainoastaan lukutoimintoihin (`describe`, `list`, `get-iam-policy`) nykytilan selvittämiseen:
  - Olemassa olevien GCP-projektien ja kansioiden tarkistus
  - Organisaatiopolitiikkojen (Organization Policies) tilan selvittäminen
  - Jaettujen aliverkkojen, reititysten ja olemassa olevien verkkoresurssien tarkistaminen
- **Ei suoria muutoksia gcloudilla**: Älä koskaan tee suoria tilamuutoksia (`create`, `update`, `delete`, `set-iam-policy` tms.) suoraan `gcloud`-komennoilla. Kaikki infrastruktuurimuutokset viedään aina deklaratiivisesti Terraformin ja FAST-rakenteen kautta.

## 4. Vianmääritys (`gcp-cloud-logging` MCP)
- **Epäonnistuneiden ajojen diagnosointi**: Jos `terraform plan` tai `terraform apply` epäonnistuu oikeus-, perimetri- tai politiikkavirheeseen (esim. Org Policy violation, VPC Service Controls denial, IAM PermissionDenied):
  - Hae välittömästi virheen tarkka syy ja konteksti Cloud Audit Logeista `gcp-cloud-logging` -MCP-palvelimen avulla.
  - Analysoi lokitietueesta `protoPayload.status`, `protoPayload.authenticationInfo` ja `protoPayload.serviceData` juurisyyn selvittämiseksi ennen korjaustoimenpiteitä.

## 5. Google FAST -konventiot
- **Cloud Foundation Fabric (FAST) -rakenne**: Noudata aina virallista `cloud-foundation-fabric` -arkkitehtuurityyliä.
- **Modulaarisuus ja uudelleenkäytettävyys**: Suosi valmiita FAST-moduuleita ja pidä resurssimäärittelyt selkeinä ja modulaarisina.
- **Data-Driven YAML -tehtaat (`factories`)**: Hyödynnä YAML-pohjaisia tehtaita aina kun mahdollista (esim. aliverkot, palomuurisäännöt, projektit, IAM-määritykset) koodin toistamisen välttämiseksi.
- **Puhdas vaiheistus (Stages)**: Pidä infrastruktuurin vaiheistus erillään ja puhtaana:
  - `0-bootstrap`: Seed-projekti, CI/CD-palvelutilit, tilasäiliöt (state buckets).
  - `1-resman`: Resurssienhallinta, kansiorakenne, ympäristöt (dev, prod).
  - `2-networking`: Jaettu verkkoinfrastruktuuri (Shared VPC, Cloud Router, VPN, palomuurit).
  - `2-security` / `3-security`: KMS, Secret Manager, CAS, keskitetyt tietoturvakomponentit.
  - `3-workloads`: Sovelluskohtaiset resurssit (GKE, Cloud Run, sovellusprojektit).
- **Nimeämisstandardit**: Noudata ehdottomasti [fast-naming.md](file:///Users/teemujappinen/ai/fast-test/.agents/rules/fast-naming.md) -ohjeistusta (ei kovakoodattuja etuliitteitä, dynaaminen interpolointi `${var.prefix}-${var.environment}-...`).
