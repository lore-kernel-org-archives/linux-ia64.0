From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 11 Jul 2005 04:48:31 +0000
Subject: Re: [patch 2.6.13-rc1] assign_irq_vector() should not panic
Message-Id: <42D1FA1F.5050903@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42C51286.5020507@jp.fujitsu.com>
In-Reply-To: <42C51286.5020507@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

Thank you very much for reviewing.

> The i386 and x86_64 versions of this return -ENOSPC rather than -1.  Perhaps
> we should do the same?

Yes, I think you're right.

> There are a couple of ia64 specific uses of assign_irq_vector in hp/sim/simeth.c
> and hp/sim/simserial.c that don't check the return value ... if you make this
> change, then they need to check for failure too.

Oh, I was very silly.
Thank you for pointing this out.

I'm attaching the updated patch that incorporates all of
your comment. Please take a look.

Thanks,
Kenji Kaneshige

---

Current assign_irq_vector() will panic if interrupt vectors is running
out. But I think how to handle the case of lack of interrupt vectors
should be handled by the caller of this function. For example, some
PCI devices can raise the interrupt signal via both MSI and I/O
APIC. So even if the driver for these device fails to allocate a
vector for MSI, the driver still has a chance to use I/O APIC based
interrupt. But currently there is no chance for these driver to use
I/O APIC based interrupt because kernel will panic when
assign_irq_vector() fails to allocate interrupt vector.

The following patch changes assign_irq_vector() for ia64 to return
negative value on error instead of panic.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---

 linux-2.6.13-rc1-kanesige/arch/ia64/hp/sim/simeth.c    |    6 ++++--
 linux-2.6.13-rc1-kanesige/arch/ia64/hp/sim/simserial.c |    7 +++++--
 linux-2.6.13-rc1-kanesige/arch/ia64/kernel/iosapic.c   |   13 +++++++++----
 linux-2.6.13-rc1-kanesige/arch/ia64/kernel/irq_ia64.c  |   15 ++-------------
 linux-2.6.13-rc1-kanesige/include/asm-ia64/hw_irq.h    |    1 -
 5 files changed, 20 insertions(+), 22 deletions(-)

diff -puN arch/ia64/hp/sim/simeth.c~remove-panic-assign_irq_vector-ia64 arch/ia64/hp/sim/simeth.c
--- linux-2.6.13-rc1/arch/ia64/hp/sim/simeth.c~remove-panic-assign_irq_vector-ia64	2005-07-11 13:19:01.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/arch/ia64/hp/sim/simeth.c	2005-07-11 13:19:01.000000000 +0900
@@ -191,7 +191,7 @@ simeth_probe1(void)
 	unsigned char mac_addr[ETH_ALEN];
 	struct simeth_local *local;
 	struct net_device *dev;
-	int fd, i, err;
+	int fd, i, err, rc;
 
 	/*
 	 * XXX Fix me
@@ -228,7 +228,9 @@ simeth_probe1(void)
 		return err;
 	}
 
-	dev->irq = assign_irq_vector(AUTO_ASSIGN);
+	if ((rc = assign_irq_vector(AUTO_ASSIGN)) < 0)
+		panic("%s: out of interrupt vectors!\n", __FUNCTION__);
+	dev->irq = rc;
 
 	/*
 	 * attach the interrupt in the simulator, this does enable interrupts
diff -puN arch/ia64/hp/sim/simserial.c~remove-panic-assign_irq_vector-ia64 arch/ia64/hp/sim/simserial.c
--- linux-2.6.13-rc1/arch/ia64/hp/sim/simserial.c~remove-panic-assign_irq_vector-ia64	2005-07-11 13:19:01.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/arch/ia64/hp/sim/simserial.c	2005-07-11 13:19:01.000000000 +0900
@@ -976,7 +976,7 @@ static struct tty_operations hp_ops = {
 static int __init
 simrs_init (void)
 {
-	int			i;
+	int			i, rc;
 	struct serial_state	*state;
 
 	if (!ia64_platform_is("hpsim"))
@@ -1011,7 +1011,10 @@ simrs_init (void)
 		if (state->type = PORT_UNKNOWN) continue;
 
 		if (!state->irq) {
-			state->irq = assign_irq_vector(AUTO_ASSIGN);
+			if ((rc = assign_irq_vector(AUTO_ASSIGN)) < 0)
+				panic("%s: out of interrupt vectors!\n",
+				      __FUNCTION__);
+			state->irq = rc;
 			ia64_ssc_connect_irq(KEYBOARD_INTR, state->irq);
 		}
 
diff -puN arch/ia64/kernel/iosapic.c~remove-panic-assign_irq_vector-ia64 arch/ia64/kernel/iosapic.c
--- linux-2.6.13-rc1/arch/ia64/kernel/iosapic.c~remove-panic-assign_irq_vector-ia64	2005-07-11 13:19:01.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/arch/ia64/kernel/iosapic.c	2005-07-11 13:19:01.000000000 +0900
@@ -489,8 +489,6 @@ static int iosapic_find_sharable_vector 
 			}
 		}
 	}
-	if (vector < 0)
-		panic("%s: out of interrupt vectors!\n", __FUNCTION__);
 
 	return vector;
 }
@@ -506,6 +504,8 @@ iosapic_reassign_vector (int vector)
 
 	if (!list_empty(&iosapic_intr_info[vector].rtes)) {
 		new_vector = assign_irq_vector(AUTO_ASSIGN);
+		if (new_vector < 0)
+			panic("%s: out of interrupt vectors!\n", __FUNCTION__);
 		printk(KERN_INFO "Reassigning vector %d to %d\n", vector, new_vector);
 		memcpy(&iosapic_intr_info[new_vector], &iosapic_intr_info[vector],
 		       sizeof(struct iosapic_intr_info));
@@ -734,9 +734,12 @@ again:
 	spin_unlock_irqrestore(&iosapic_lock, flags);
 
 	/* If vector is running out, we try to find a sharable vector */
-	vector = assign_irq_vector_nopanic(AUTO_ASSIGN);
-	if (vector < 0)
+	vector = assign_irq_vector(AUTO_ASSIGN);
+	if (vector < 0) {
 		vector = iosapic_find_sharable_vector(trigger, polarity);
+		if (vector < 0)
+			panic("%s: out of interrupt vectors!\n", __FUNCTION__);
+	}
 
 	spin_lock_irqsave(&irq_descp(vector)->lock, flags);
 	spin_lock(&iosapic_lock);
@@ -884,6 +887,8 @@ iosapic_register_platform_intr (u32 int_
 		break;
 	      case ACPI_INTERRUPT_INIT:
 		vector = assign_irq_vector(AUTO_ASSIGN);
+		if (vector < 0)
+			panic("%s: out of interrupt vectors!\n", __FUNCTION__);
 		delivery = IOSAPIC_INIT;
 		break;
 	      case ACPI_INTERRUPT_CPEI:
diff -puN arch/ia64/kernel/irq_ia64.c~remove-panic-assign_irq_vector-ia64 arch/ia64/kernel/irq_ia64.c
--- linux-2.6.13-rc1/arch/ia64/kernel/irq_ia64.c~remove-panic-assign_irq_vector-ia64	2005-07-11 13:19:01.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/arch/ia64/kernel/irq_ia64.c	2005-07-11 13:19:01.000000000 +0900
@@ -63,30 +63,19 @@ EXPORT_SYMBOL(isa_irq_to_vector_map);
 static unsigned long ia64_vector_mask[BITS_TO_LONGS(IA64_NUM_DEVICE_VECTORS)];
 
 int
-assign_irq_vector_nopanic (int irq)
+assign_irq_vector (int irq)
 {
 	int pos, vector;
  again:
 	pos = find_first_zero_bit(ia64_vector_mask, IA64_NUM_DEVICE_VECTORS);
 	vector = IA64_FIRST_DEVICE_VECTOR + pos;
 	if (vector > IA64_LAST_DEVICE_VECTOR)
-		return -1;
+		return -ENOSPC;
 	if (test_and_set_bit(pos, ia64_vector_mask))
 		goto again;
 	return vector;
 }
 
-int
-assign_irq_vector (int irq)
-{
-	int vector = assign_irq_vector_nopanic(irq);
-
-	if (vector < 0)
-		panic("assign_irq_vector: out of interrupt vectors!");
-
-	return vector;
-}
-
 void
 free_irq_vector (int vector)
 {
diff -puN include/asm-ia64/hw_irq.h~remove-panic-assign_irq_vector-ia64 include/asm-ia64/hw_irq.h
--- linux-2.6.13-rc1/include/asm-ia64/hw_irq.h~remove-panic-assign_irq_vector-ia64	2005-07-11 13:19:01.000000000 +0900
+++ linux-2.6.13-rc1-kanesige/include/asm-ia64/hw_irq.h	2005-07-11 13:19:01.000000000 +0900
@@ -81,7 +81,6 @@ extern __u8 isa_irq_to_vector_map[16];
 
 extern struct hw_interrupt_type irq_type_ia64_lsapic;	/* CPU-internal interrupt controller */
 
-extern int assign_irq_vector_nopanic (int irq); /* allocate a free vector without panic */
 extern int assign_irq_vector (int irq);	/* allocate a free vector */
 extern void free_irq_vector (int vector);
 extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect);

_

