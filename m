From: al.stone@linaro.org
Date: Wed, 25 Feb 2015 00:36:17 +0000
Subject: [PATCH v3 1/9] ACPI: fix all errors reported by cleanpatch.pl in osl.c
Message-Id: <1424824585-6405-2-git-send-email-al.stone@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424824585-6405-1-git-send-email-al.stone@linaro.org>
In-Reply-To: <1424824585-6405-1-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rjw@rjwysocki.net, lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, robert.moore@intel.com, tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-arm-kernel@lists.infradead.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org

From: Al Stone <al.stone@linaro.org>

In preparation for later splitting out some of the arch-dependent code from
osl.c, clean up the errors reported by checkpatch.pl.  They fell into these
classes:

   -- remove the FSF address from the GPL notice
   -- "foo * bar" should be "foo *bar" (and the ** variation of same)
   -- a return is not a function, so parentheses are not required.

Signed-off-by: Al Stone <al.stone@linaro.org>
---
 drivers/acpi/osl.c | 38 +++++++++++++++++---------------------
 1 file changed, 17 insertions(+), 21 deletions(-)

diff --git a/drivers/acpi/osl.c b/drivers/acpi/osl.c
index 39748bb..1dc3a3b 100644
--- a/drivers/acpi/osl.c
+++ b/drivers/acpi/osl.c
@@ -19,10 +19,6 @@
  *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *  GNU General Public License for more details.
  *
- *  You should have received a copy of the GNU General Public License
- *  along with this program; if not, write to the Free Software
- *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- *
  * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  *
  */
@@ -526,7 +522,7 @@ EXPORT_SYMBOL(acpi_os_unmap_generic_address);
 
 #ifdef ACPI_FUTURE_USAGE
 acpi_status
-acpi_os_get_physical_address(void *virt, acpi_physical_address * phys)
+acpi_os_get_physical_address(void *virt, acpi_physical_address *phys)
 {
 	if (!phys || !virt)
 		return AE_BAD_PARAMETER;
@@ -543,7 +539,7 @@ static char acpi_os_name[ACPI_MAX_OVERRIDE_LEN];
 
 acpi_status
 acpi_os_predefined_override(const struct acpi_predefined_names *init_val,
-			    acpi_string * new_val)
+			    acpi_string *new_val)
 {
 	if (!init_val || !new_val)
 		return AE_BAD_PARAMETER;
@@ -714,8 +710,8 @@ static void acpi_table_taint(struct acpi_table_header *table)
 
 
 acpi_status
-acpi_os_table_override(struct acpi_table_header * existing_table,
-		       struct acpi_table_header ** new_table)
+acpi_os_table_override(struct acpi_table_header *existing_table,
+		       struct acpi_table_header **new_table)
 {
 	if (!existing_table || !new_table)
 		return AE_BAD_PARAMETER;
@@ -889,7 +885,7 @@ u64 acpi_os_get_timer(void)
 	return time_ns;
 }
 
-acpi_status acpi_os_read_port(acpi_io_address port, u32 * value, u32 width)
+acpi_status acpi_os_read_port(acpi_io_address port, u32 *value, u32 width)
 {
 	u32 dummy;
 
@@ -1046,7 +1042,7 @@ acpi_os_write_memory(acpi_physical_address phys_addr, u64 value, u32 width)
 }
 
 acpi_status
-acpi_os_read_pci_configuration(struct acpi_pci_id * pci_id, u32 reg,
+acpi_os_read_pci_configuration(struct acpi_pci_id *pci_id, u32 reg,
 			       u64 *value, u32 width)
 {
 	int result, size;
@@ -1074,11 +1070,11 @@ acpi_os_read_pci_configuration(struct acpi_pci_id * pci_id, u32 reg,
 				reg, size, &value32);
 	*value = value32;
 
-	return (result ? AE_ERROR : AE_OK);
+	return result ? AE_ERROR : AE_OK;
 }
 
 acpi_status
-acpi_os_write_pci_configuration(struct acpi_pci_id * pci_id, u32 reg,
+acpi_os_write_pci_configuration(struct acpi_pci_id *pci_id, u32 reg,
 				u64 value, u32 width)
 {
 	int result, size;
@@ -1101,7 +1097,7 @@ acpi_os_write_pci_configuration(struct acpi_pci_id * pci_id, u32 reg,
 				PCI_DEVFN(pci_id->device, pci_id->function),
 				reg, size, value);
 
-	return (result ? AE_ERROR : AE_OK);
+	return result ? AE_ERROR : AE_OK;
 }
 
 static void acpi_os_execute_deferred(struct work_struct *work)
@@ -1247,7 +1243,7 @@ bool acpi_queue_hotplug_work(struct work_struct *work)
 }
 
 acpi_status
-acpi_os_create_semaphore(u32 max_units, u32 initial_units, acpi_handle * handle)
+acpi_os_create_semaphore(u32 max_units, u32 initial_units, acpi_handle *handle)
 {
 	struct semaphore *sem = NULL;
 
@@ -1735,7 +1731,7 @@ void acpi_os_release_lock(acpi_spinlock lockp, acpi_cpu_flags flags)
  ******************************************************************************/
 
 acpi_status
-acpi_os_create_cache(char *name, u16 size, u16 depth, acpi_cache_t ** cache)
+acpi_os_create_cache(char *name, u16 size, u16 depth, acpi_cache_t **cache)
 {
 	*cache = kmem_cache_create(name, size, 0, 0, NULL);
 	if (*cache = NULL)
@@ -1756,10 +1752,10 @@ acpi_os_create_cache(char *name, u16 size, u16 depth, acpi_cache_t ** cache)
  *
  ******************************************************************************/
 
-acpi_status acpi_os_purge_cache(acpi_cache_t * cache)
+acpi_status acpi_os_purge_cache(acpi_cache_t *cache)
 {
 	kmem_cache_shrink(cache);
-	return (AE_OK);
+	return AE_OK;
 }
 
 /*******************************************************************************
@@ -1775,10 +1771,10 @@ acpi_status acpi_os_purge_cache(acpi_cache_t * cache)
  *
  ******************************************************************************/
 
-acpi_status acpi_os_delete_cache(acpi_cache_t * cache)
+acpi_status acpi_os_delete_cache(acpi_cache_t *cache)
 {
 	kmem_cache_destroy(cache);
-	return (AE_OK);
+	return AE_OK;
 }
 
 /*******************************************************************************
@@ -1795,10 +1791,10 @@ acpi_status acpi_os_delete_cache(acpi_cache_t * cache)
  *
  ******************************************************************************/
 
-acpi_status acpi_os_release_object(acpi_cache_t * cache, void *object)
+acpi_status acpi_os_release_object(acpi_cache_t *cache, void *object)
 {
 	kmem_cache_free(cache, object);
-	return (AE_OK);
+	return AE_OK;
 }
 #endif
 
-- 
2.1.0

