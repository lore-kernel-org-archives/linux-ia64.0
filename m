From: Rajesh Shah <rajesh.shah@intel.com>
Date: Fri, 21 Jan 2005 02:54:09 +0000
Subject: Re: [Pcihpd-discuss] [PATCH] Convert acpiphp to use generic resource code
Message-Id: <20050120185409.A24471@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050119183853.C12618@unix-os.sc.intel.com>
In-Reply-To: <20050119183853.C12618@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 19, 2005 at 06:51:20PM +0000, Matthew Wilcox wrote:
> 
>  static void remove_bridge(acpi_handle handle)
>  {
> -	/* No-op for now .. */
> +	struct list_head *list, *tmp;
> +	struct acpiphp_bridge *bridge;
> +	struct acpiphp_slot *slot;
> +	acpi_status status;
> +
> +	bridge = acpiphp_handle_to_bridge(handle);
> +	if (!bridge) {
> +		err("Could not find bridge for handle %p\n", handle);
> +		return;
> +	}

A root bridge may not have directly attached hotpluggable
slots under it. Instead, it may have p2p bridges with slots
under it. In this case, we need to clean up the p2p bridges
and slots properly too. Patch below applies on top of the
original patch, and fixes this problem. Without this, acpiphp
leaves behind notify handlers on module unload, and subsequent
module load attempts don't work properly too. Patch was tested
on an ia64 Tiger4 box.

Signed-off-by: Rajesh Shah <rajesh.shah@intel.com>
---

 linux-2.6.11-rc1-mm2-t2-rshah1/drivers/pci/hotplug/acpiphp_glue.c |   34 +++++++---
 1 files changed, 26 insertions(+), 8 deletions(-)

diff -puN drivers/pci/hotplug/acpiphp_glue.c~unload_cleanup drivers/pci/hotplug/acpiphp_glue.c
--- linux-2.6.11-rc1-mm2-t2/drivers/pci/hotplug/acpiphp_glue.c~unload_cleanup	2005-01-20 17:18:19.839605127 -0800
+++ linux-2.6.11-rc1-mm2-t2-rshah1/drivers/pci/hotplug/acpiphp_glue.c	2005-01-20 17:57:35.978248139 -0800
@@ -486,18 +486,12 @@ static struct acpiphp_bridge *acpiphp_ha
 	return NULL;
 }
 
-static void remove_bridge(acpi_handle handle)
+static void cleanup_bridge(struct acpiphp_bridge *bridge)
 {
 	struct list_head *list, *tmp;
-	struct acpiphp_bridge *bridge;
 	struct acpiphp_slot *slot;
 	acpi_status status;
-
-	bridge = acpiphp_handle_to_bridge(handle);
-	if (!bridge) {
-		err("Could not find bridge for handle %p\n", handle);
-		return;
-	}
+	acpi_handle handle = bridge->handle;
 
 	status = acpi_remove_notify_handler(handle, ACPI_SYSTEM_NOTIFY,
 					    handle_hotplug_event_bridge);
@@ -528,6 +522,30 @@ static void remove_bridge(acpi_handle ha
 	kfree(bridge);
 }
 
+static acpi_status
+cleanup_p2p_bridge(acpi_handle handle, u32 lvl, void *context, void **rv)
+{
+	struct acpiphp_bridge *bridge;
+
+	if (!(bridge = acpiphp_handle_to_bridge(handle)))
+		return AE_OK;
+	cleanup_bridge(bridge);
+	return AE_OK;
+}
+
+static void remove_bridge(acpi_handle handle)
+{
+	struct acpiphp_bridge *bridge;
+
+	bridge = acpiphp_handle_to_bridge(handle);
+	if (bridge) {
+		cleanup_bridge(bridge);
+	} else {
+		/* clean-up p2p bridges under this host bridge */
+		acpi_walk_namespace(ACPI_TYPE_DEVICE, handle,
+				(u32)1, cleanup_p2p_bridge, NULL, NULL);
+	}
+}
 
 static int power_on_slot(struct acpiphp_slot *slot)
 {
_
