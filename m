From: Jack Steiner <steiner@sgi.com>
Date: Thu, 07 Jun 2001 22:00:11 +0000
Subject: [Linux-ia64] 2.4.5 hangs in smp_call_function.
Message-Id: <marc-linux-ia64-105590693005699@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Since upgrading to 2.4.5, we have seen several system hangs 
where multiple cpus were spinning in smp_call_function.

The problem appears to be caused by the code in smp_call_function()
that resends an IPI if a timeout expires. 

Resending a IPI_CALL_FUNC IPI can cause a cpu to process the "call_func"
request twice and corrupt the "data.finished" count by incrementing the 
count twice for one request. 


Here is a patch that corrects the problem. I'm not sure what the
correct timeout should be - I increase it from HZ to 400000UL
but more investigation need to be done to determine the optimum
value. Since the "resendIPI" code is not needed with C0 stepping
cpus, I didnt worry too much about the timeout value.

I havent seen any more hangs after applying the patch. 



----------------------------------------------------------------------------------
diff -Naur linux_base/arch/ia64/kernel/smp.c linux/arch/ia64/kernel/smp.c
--- linux_base/arch/ia64/kernel/smp.c	Thu Jun  7 14:44:07 2001
+++ linux/arch/ia64/kernel/smp.c	Thu Jun  7 14:46:05 2001
@@ -244,6 +244,28 @@
 	send_IPI_single(smp_processor_id(), op);
 }
 
+#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC) || defined(CONFIG_ITANIUM_PTCG))
+void
+resend_lost_IPI (void)
+{
+	/*
+	 * Really need a null IPI but since this rarely should happen & since this code
+	 * will go away, lets not add one.
+	 */
+	send_IPI_allbutself(IPI_RESCHEDULE);
+}
+
+void
+resend_lost_IPI_single (int cpu)
+{
+	/*
+	 * Really need a null IPI but since this rarely should happen & since this code
+	 * will go away, lets not add one.
+	 */
+	send_IPI_single(cpu, IPI_RESCHEDULE);
+}
+#endif /* CONFIG_ITANIUM_ASTEP_SPECIFIC || CONFIG_ITANIUM_BSTEP_SPECIFIC || CONFIG_ITANIUM_PTCG */
+
 void
 smp_send_reschedule (int cpu)
 {
@@ -258,16 +280,6 @@
 	send_IPI_allbutself(IPI_FLUSH_TLB);
 }
 
-void
-smp_resend_flush_tlb (void)
-{
-	/*
-	 * Really need a null IPI but since this rarely should happen & since this code
-	 * will go away, lets not add one.
-	 */
-	send_IPI_allbutself(IPI_RESCHEDULE);
-}
-
 #endif  /* !CONFIG_ITANIUM_PTCG */
 
 void
@@ -314,16 +326,18 @@
 	spin_lock_bh(&call_lock);
 	call_data = &data;
 
-  resend:
   	send_IPI_single(cpuid, IPI_CALL_FUNC);
 
 #if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC))
 	/*  Wait for response */
-	timeout = jiffies + HZ;
+  again:
+	timeout = jiffies + 400000UL;
 	while ((atomic_read(&data.started) != cpus) && time_before(jiffies, timeout))
 		barrier();
-	if (atomic_read(&data.started) != cpus)
-		goto resend;
+	if (atomic_read(&data.started) != cpus) {
+		resend_lost_IPI_single(cpuid);
+		goto again;
+	}
 #else
 	/* Wait for response */
 	while (atomic_read(&data.started) != cpus)
@@ -379,17 +393,19 @@
 	spin_lock_bh(&call_lock);
 	call_data = &data;
 
-  resend:
 	/*  Send a message to all other CPUs and wait for them to respond */
 	send_IPI_allbutself(IPI_CALL_FUNC);
 
 #if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC))
 	/* Wait for response */
-	timeout = jiffies + HZ;
+  again:
+	timeout = jiffies + 400000UL;
 	while ((atomic_read(&data.started) != cpus) && time_before(jiffies, timeout))
 		barrier();
-	if (atomic_read(&data.started) != cpus)
-		goto resend;
+	if (atomic_read(&data.started) != cpus) {
+		resend_lost_IPI();
+		goto again;
+	}
 #else
 	/* Wait for response */
 	while (atomic_read(&data.started) != cpus)
diff -Naur linux_base/arch/ia64/mm/tlb.c linux/arch/ia64/mm/tlb.c
--- linux_base/arch/ia64/mm/tlb.c	Thu Jun  7 14:44:07 2001
+++ linux/arch/ia64/mm/tlb.c	Thu Jun  7 14:46:07 2001
@@ -99,12 +99,12 @@
 	 */
 #if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC)
 	{
-		extern void smp_resend_flush_tlb (void);
+		extern void smp_resend_lost_IPI (void);
 		unsigned long start = ia64_get_itc();
 
 		while (atomic_read(&flush_cpu_count) > 0) {
 			if ((ia64_get_itc() - start) > 400000UL) {
-				smp_resend_flush_tlb();
+				smp_resend_lost_IPI();
 				start = ia64_get_itc();
 			}
 		}

-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


