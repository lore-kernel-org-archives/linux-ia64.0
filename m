From: root <davidm@hpl.hp.com>
Date: Tue, 12 Jun 2001 06:37:53 +0000
Subject: Re: [Linux-ia64] 2.4.5 hangs in smp_call_function.
Message-Id: <marc-linux-ia64-105590693005715@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005699@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005699@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 7 Jun 2001 17:00:11 -0500 (CDT), Jack Steiner <steiner@sgi.com> said:

  Jack> Since upgrading to 2.4.5, we have seen several system hangs
  Jack> where multiple cpus were spinning in smp_call_function.

  Jack> The problem appears to be caused by the code in
  Jack> smp_call_function() that resends an IPI if a timeout expires.

It turns out that the real problem here was that the IPI timeout
mechanism was enabled even for B3 step CPUs.  The patch below fixes
this.  Thanks to Jack for tracking this down.

	--david

--- arch/ia64/kernel/smp.c~	Tue Jun  5 10:18:34 2001
+++ arch/ia64/kernel/smp.c	Mon Jun 11 15:29:40 2001
@@ -285,7 +285,8 @@
 {
 	struct call_data_struct data;
 	int cpus = 1;
-#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC))
+#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B0_SPECIFIC) \
+     || defined(CONFIG_ITANIUM_B1_SPECIFIC) || defined(CONFIG_ITANIUM_B2_SPECIFIC))
 	unsigned long timeout;
 #endif
 
@@ -307,7 +308,8 @@
   resend:
   	send_IPI_single(cpuid, IPI_CALL_FUNC);
 
-#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC))
+#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B0_SPECIFIC) \
+     || defined(CONFIG_ITANIUM_B1_SPECIFIC) || defined(CONFIG_ITANIUM_B2_SPECIFIC))
 	/*  Wait for response */
 	timeout = jiffies + HZ;
 	while ((atomic_read(&data.started) != cpus) && time_before(jiffies, timeout))
@@ -352,7 +354,8 @@
 {
 	struct call_data_struct data;
 	int cpus = smp_num_cpus-1;
-#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC))
+#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B0_SPECIFIC) \
+     || defined(CONFIG_ITANIUM_B1_SPECIFIC) || defined(CONFIG_ITANIUM_B2_SPECIFIC))
 	unsigned long timeout;
 #endif
 
@@ -373,7 +376,8 @@
 	/*  Send a message to all other CPUs and wait for them to respond */
 	send_IPI_allbutself(IPI_CALL_FUNC);
 
-#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP_SPECIFIC))
+#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B0_SPECIFIC) \
+     || defined(CONFIG_ITANIUM_B1_SPECIFIC) || defined(CONFIG_ITANIUM_B2_SPECIFIC))
 	/* Wait for response */
 	timeout = jiffies + HZ;
 	while ((atomic_read(&data.started) != cpus) && time_before(jiffies, timeout))

