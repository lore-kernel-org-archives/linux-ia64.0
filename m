From: Matt Domsch <Matt_Domsch@dell.com>
Date: Wed, 04 Jan 2006 22:19:37 +0000
Subject: [PATCH 2.6.15 2/2] ipmi: use CONFIG_DMI instead of CONFIG_X86
Message-Id: <20060104221937.GB26064@lists.us.dell.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, ak@suse.de, openipmi-developer@lists.sourceforge.net, akpm@osdl.org
Cc: linux-kernel@vger.kernel.org

With Andi Kleen's x86_64 patch to use DMI, and my ia64 to use DMI,
there is now a new CONFIG_DMI option which takes the place of
CONFIG_X86 to denote the availability of the DMI functions.  Make the
IPMI driver use CONFIG_DMI instead.

Tested on ia64 2.6.15 kernel plus the previous patch, on a Dell
PowerEdge 7250 Itanium2 server, and it now autodetects the IPMI KCS
driver as expected.

Signed-off-by: Matt Domsch <Matt_Domsch@dell.com>


-- 
Matt Domsch
Software Architect
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

diff --git a/drivers/char/ipmi/ipmi_si_intf.c b/drivers/char/ipmi/ipmi_si_intf.c
index beea450..c67ef3e 100644
--- a/drivers/char/ipmi/ipmi_si_intf.c
+++ b/drivers/char/ipmi/ipmi_si_intf.c
@@ -1056,7 +1056,7 @@ MODULE_PARM_DESC(slave_addrs, "Set the d
 #define IPMI_MEM_ADDR_SPACE 1
 #define IPMI_IO_ADDR_SPACE  2
 
-#if defined(CONFIG_ACPI) || defined(CONFIG_X86) || defined(CONFIG_PCI)
+#if defined(CONFIG_ACPI) || defined(CONFIG_DMI) || defined(CONFIG_PCI)
 static int is_new_interface(int intf, u8 addr_space, unsigned long base_addr)
 {
 	int i;
@@ -1669,7 +1669,7 @@ static int try_init_acpi(int intf_num, s
 }
 #endif
 
-#ifdef CONFIG_X86
+#ifdef CONFIG_DMI
 typedef struct dmi_ipmi_data
 {
 	u8   		type;
@@ -1829,7 +1829,7 @@ static int try_init_smbios(int intf_num,
 	       ipmi_data->slave_addr);
 	return 0;
 }
-#endif /* CONFIG_X86 */
+#endif /* CONFIG_DMI */
 
 #ifdef CONFIG_PCI
 
@@ -2222,7 +2222,7 @@ static int init_one_smi(int intf_num, st
 	if (rv && si_trydefaults)
 		rv = try_init_acpi(intf_num, &new_smi);
 #endif
-#ifdef CONFIG_X86
+#ifdef CONFIG_DMI
 	if (rv && si_trydefaults)
 		rv = try_init_smbios(intf_num, &new_smi);
 #endif
@@ -2433,7 +2433,7 @@ static __init int init_ipmi_si(void)
 
 	printk(KERN_INFO "IPMI System Interface driver.\n");
 
-#ifdef CONFIG_X86
+#ifdef CONFIG_DMI
 	dmi_find_bmc();
 #endif
 
