From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 07 Jan 2010 19:58:56 +0000
Subject: [PATCH 2/2] agp/hp: fail gracefully if we don't find an IOC
Message-Id: <20100107195856.1790.75016.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Bail out if we don't find an enclosing IOC.  Previously, if we didn't
find one, we tried to set things up using garbage for the SBA/IOC register
address, which causes a crash.

This crash only happens if firmware supplies a defective ACPI namespace, so
it doesn't fix any problems in the field.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
---

 drivers/char/agp/hp-agp.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)


diff --git a/drivers/char/agp/hp-agp.c b/drivers/char/agp/hp-agp.c
index dc8a6f7..58752b7 100644
--- a/drivers/char/agp/hp-agp.c
+++ b/drivers/char/agp/hp-agp.c
@@ -508,6 +508,9 @@ zx1_gart_probe (acpi_handle obj, u32 depth, void *context, void **ret)
 		handle = parent;
 	} while (ACPI_SUCCESS(status));
 
+	if (ACPI_FAILURE(status))
+		return AE_OK;	/* found no enclosing IOC */
+
 	if (hp_zx1_setup(sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa))
 		return AE_OK;
 

