From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 11 Aug 2005 03:18:20 +0000
Subject: Re: 2.6.13-rc6 doesn't build with hotplug option off
Message-Id: <42FAC37C.8010008@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508100132.j7A1Wqg05828@unix-os.sc.intel.com>
In-Reply-To: <200508100132.j7A1Wqg05828@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

>>I think the following patch will remove this compile error.
>>Could you try this? or could you send me your .config?
>>Unfortunately, I don't have the .config in which
>>CONFIG_HOTPLUG is not set.
> 
> 
> Yeah, it should work now.  config file attached.

I tested the following patch with CONFIG_HOTPLUG off and
with CONFIG_HOTPLUG on, and confirmed that it removes the
issue.

Tony, could you apply this patch?
(This patch is same as I posted in the previous mail)

Thanks,
Kenji Kaneshige
---

This patch removes the following stupid compile error that happens
when CONFIG_HOTPLUG is not defined on ia64.

     LD      .tmp_vmlinux1
     arch/ia64/kernel/built-in.o(.text+0x712): In function `acpi_unregister_ioapic':
     : undefined reference to `iosapic_remove'
     make: *** [.tmp_vmlinux1] Error 1

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
---

 include/asm-ia64/iosapic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN include/asm-ia64/iosapic.h~fix-compile-error-acpi_unregister_ioapic-ia64 include/asm-ia64/iosapic.h
--- linux-2.6.13-rc6/include/asm-ia64/iosapic.h~fix-compile-error-acpi_unregister_ioapic-ia64	2005-08-10 18:02:44.000000000 +0900
+++ linux-2.6.13-rc6-kanesige/include/asm-ia64/iosapic.h	2005-08-10 18:35:33.000000000 +0900
@@ -75,6 +75,8 @@ extern int __devinit iosapic_init (unsig
 				    unsigned int gsi_base);
 #ifdef CONFIG_HOTPLUG
 extern int iosapic_remove (unsigned int gsi_base);
+#else
+#define iosapic_remove(gsi_base)				(-EINVAL)
 #endif /* CONFIG_HOTPLUG */
 extern int gsi_to_vector (unsigned int gsi);
 extern int gsi_to_irq (unsigned int gsi);
@@ -102,9 +104,7 @@ extern void __devinit map_iosapic_to_nod
 #else
 #define iosapic_system_init(pcat_compat)			do { } while (0)
 #define iosapic_init(address,gsi_base)				(-EINVAL)
-#ifdef CONFIG_HOTPLUG
 #define iosapic_remove(gsi_base)				(-ENODEV)
-#endif /* CONFIG_HOTPLUG */
 #define iosapic_register_intr(gsi,polarity,trigger)		(gsi)
 #define iosapic_unregister_intr(irq)				do { } while (0)
 #define iosapic_override_isa_irq(isa_irq,gsi,polarity,trigger)	do { } while (0)
_
