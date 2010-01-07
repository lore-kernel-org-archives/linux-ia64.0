From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 07 Jan 2010 19:58:46 +0000
Subject: [PATCH 0/2] agp/hp: fix zx1_gart_probe oops
Message-Id: <20100107195738.1790.47307.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The first patch fixes a crash reported by =C3=89meric Maschino while loadin=
g the
hp-agp driver.  This affects all HP zx1/zx2 ia64 systems with AGP, so the f=
ix
needs to go in 2.6.33.

There's no hurry with the second patch; it just fixes a crash that would ha=
ppen
with certain firmware defects, but there's no firmware in the field with th=
at
specific defect.

---

Bjorn Helgaas (2):
      ACPICA: acpi_get_object_info(): fixup array -> pointer conversion
      agp/hp: fail gracefully if we don't find an IOC

 drivers/char/agp/hp-agp.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)
