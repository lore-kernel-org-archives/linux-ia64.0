From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Fri, 22 Feb 2008 17:14:20 +0000
Subject: ia64_mca_cpe_int_handler
Message-Id: <47BF02EC.4080102@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------010507000806020104060609"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------010507000806020104060609
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The ia64_mca_cpe_int_handler() in 2.6.24 goes something like this:

ia64_mca_cpe_int_handler (int cpe_irq, void *arg)
{
...
	/* SAL spec states this should run w/ interrupts enabled */
	local_irq_enable();

	spin_lock(&cpe_history_lock);
...
	spin_unlock(&cpe_history_lock);

	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE);
}

I think the interrupts are enabled too early. I just have caught a dead lock:
I have got nested ia64_mca_cpe_int_handler()-s, the first instance has
been interrupted somewhere between spin_lock(&cpe_history_lock) and
spin_unlock(&cpe_history_lock). Obviously, the second instance will never get
the lock.
The previous versions, e.g. 2.6.18, were not safe either:

ia64_mca_cpe_int_handler (int cpe_irq, void *arg, struct pt_regs *ptregs)
{
...
        /* SAL spec states this should run w/ interrupts enabled */
        local_irq_enable();

        /* Get the CPE error record and log it */
        ia64_mca_log_sal_error_record(SAL_INFO_TYPE_CPE);

        spin_lock(&cpe_history_lock);
...
	spin_unlock(&cpe_history_lock);
}

I think the interrupts have to be blocked while we are inside the lock-
protected region.
I can think of something like this below. Please have a look at this patch.

Thanks,

Zoltan Menyhart


--------------010507000806020104060609
Content-Type: text/plain;
 name="mca.c-patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mca.c-patch"

--- linux-2.6.24-old/arch/ia64/kernel/mca.c	2008-02-22 18:09:12.000000000 +0100
+++ linux-2.6.24/arch/ia64/kernel/mca.c	2008-02-22 18:09:26.000000000 +0100
@@ -436,6 +436,10 @@
 	static const char * const rec_name[] = { "MCA", "INIT", "CMC", "CPE" };
 #endif
 
+	if (irq_safe){
+		/* SAL spec states this should run w/ interrupts enabled */
+		local_irq_enable();
+	}
 	size = ia64_log_get(sal_info_type, &buffer, irq_safe);
 	if (!size)
 		return;
@@ -512,9 +516,6 @@
 	IA64_MCA_DEBUG("%s: received interrupt vector = %#x on CPU %d\n",
 		       __FUNCTION__, cpe_irq, smp_processor_id());
 
-	/* SAL spec states this should run w/ interrupts enabled */
-	local_irq_enable();
-
 	spin_lock(&cpe_history_lock);
 	if (!cpe_poll_enabled && cpe_vector >= 0) {
 
@@ -1324,9 +1325,6 @@
 	IA64_MCA_DEBUG("%s: received interrupt vector = %#x on CPU %d\n",
 		       __FUNCTION__, cmc_irq, smp_processor_id());
 
-	/* SAL spec states this should run w/ interrupts enabled */
-	local_irq_enable();
-
 	spin_lock(&cmc_history_lock);
 	if (!cmc_polling_enabled) {
 		int i, count = 1; /* we know 1 happened now */

--------------010507000806020104060609--
