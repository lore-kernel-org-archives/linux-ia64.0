From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Fri, 03 Aug 2007 05:22:40 +0000
Subject: Re: [RFC][PATCH 0/2] SN platform needs platform_irq_to_vector?
Message-Id: <1186118560.3985.56.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186028871.3875.12.camel@kane-linux>
In-Reply-To: <1186028871.3875.12.camel@kane-linux>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2007-08-02 (木) の 09:50 -0500 に Russ Anderson さんは書きました: 
> There seems to be an issue with this for CPEs.  The net result is
> when there is a correctable error, the interrupt does not get handled
> resulting in this message:
> 
> -----------------------------------------------------------------
> irq 30, desc: a000000100c37000, depth: 1, count: 0, unhandled: 0
> ->handle_irq():  a0000001009a6a50, __end_rodata+0x5010/0x225c0
> ->chip(): a000000100dfee80, irq_type_sn+0x0/0x80
> ->action(): 0000000000000000
>   IRQ_DISABLED set
> Unexpected irq vector 0x1e on CPU 0!
> -----------------------------------------------------------------
> 
> The CPE handler should be on irq 0x1e (30).  See IA64_CPE_VECTOR .
> In ia64_mca_late_init() the line
> 
>            if (irq_to_vector(irq) = cpe_vector) {
> 
> is never true, so setup_irq(irq, &mca_cpe_irqaction); never gets called.
> 

Could you please check if [PATCH 2/2] is applied on your kernel again?

With [PATCH 2/2], irq_to_vector(irq) just returns the same value as
vector. So the line

	for (irq = 0; irq < NR_IRQS; ++irq)
		if (irq_to_vector(irq) = cpe_vector) {

should be true if cpe_vector is within 0 to NR_IRQ-1.

I'm sorry but the important thing was missing in my "FYI".
I said like folows:

> The "irq = vector" is always true in the following cases:
>     ...
>     - Vectors outside FIRST_DEVICE_VECTOR to LAST_DEVICE_VECTOR

But if the irq is not initialized by __bind_irq_vector() through
bind_irq_vector() or register_percpu_irq(), irq_to_vector(irq) returns 
IRQ_VECTOR_UNASSIGNED, which is zero.

So if [PATCH 2/2] was not applied, irq_to_vector(IA64_CPE_VECTOR)
may returns zero and "irq_to_vector(irq) = cpe_vector" would never
be true.

BTW, as you pointed out in the other mail, sn_irq_to_vector() will
truncate any IRQ > 255. Because of this, "if (irq_to_vector(irq) = 
cpe_vector)" check will true several times. But I don't know if
this is the cause of CPE problem, becasue CPE is still fine on my
dig64 kernel even when the following debug patch applied.

Thanks,
Kenji Kaneshige


---
 arch/ia64/kernel/irq.c    |    6 ++++--
 include/asm-ia64/hw_irq.h |    6 ++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

Index: linux-2.6.23-rc1/arch/ia64/kernel/irq.c
=================================--- linux-2.6.23-rc1.orig/arch/ia64/kernel/irq.c
+++ linux-2.6.23-rc1/arch/ia64/kernel/irq.c
@@ -35,12 +35,14 @@ void ack_bad_irq(unsigned int irq)
 #ifdef CONFIG_IA64_GENERIC
 ia64_vector __ia64_irq_to_vector(int irq)
 {
-	return irq_cfg[irq].vector;
+	return (ia64_vector)irq;
+	//return irq_cfg[irq].vector;
 }
 
 unsigned int __ia64_local_vector_to_irq (ia64_vector vec)
 {
-	return __get_cpu_var(vector_irq)[vec];
+	return (unsigned int)vec;
+	//return __get_cpu_var(vector_irq)[vec];
 }
 #endif
 
Index: linux-2.6.23-rc1/include/asm-ia64/hw_irq.h
=================================--- linux-2.6.23-rc1.orig/include/asm-ia64/hw_irq.h
+++ linux-2.6.23-rc1/include/asm-ia64/hw_irq.h
@@ -126,13 +126,15 @@ extern irq_desc_t irq_desc[NR_IRQS];
 #ifndef CONFIG_IA64_GENERIC
 static inline ia64_vector __ia64_irq_to_vector(int irq)
 {
-	return irq_cfg[irq].vector;
+	return (ia64_vector)irq;
+	//return irq_cfg[irq].vector;
 }
 
 static inline unsigned int
 __ia64_local_vector_to_irq (ia64_vector vec)
 {
-	return __get_cpu_var(vector_irq)[vec];
+	return (unsigned int)vec;
+	//return __get_cpu_var(vector_irq)[vec];
 }
 #endif
 


