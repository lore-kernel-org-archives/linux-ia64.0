From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 05 Aug 2004 11:03:00 +0000
Subject: [PATCH&RFC 1/2] OS_MCA Recovery from poisoned memory read
Message-Id: <411213E4.6050009@jp.fujitsu.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------020900060904010906070100"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------020900060904010906070100
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

This is the latest OS_MCA handler which try to do recovery from
multibit-ECC/poisoned memory-read error on user-land.


Along the way, I already posted some prototypes of the OS_MCA
handler to IA64ML requesting for comments.  The most urgent
problem was that I couldn't test my patch enough because of the
lack of tools such as error(MCA) injections.

However, with Tony's great cooperation, today's patch have
passed all of my running tests on Intel's Tiger4.  Of course,
I confirmed that the handler kills a user process which
encounters MCA caused by memory read, and that the system
is prevented from down after the MCA in the situation.
Also, the isolation of erroneous/poisoned memory is realized
by PG_Reserved flag.

This handler actually recover your system from memory-read MCA.


This time, I suppose a functional pointer for OS_MCA.
Because it:
   - allows OS_MCA module:
       - rmmod if you want
   - allows handler replacement on runtime:
       - easy to debug/test/update?
   - allows platform specific handling:
       - increase the reliability of generic kernel

I'd like to request for comment about this functional pointer.
If no one want to do such complicated trick, I will make a little
fix for my patch to work all the time as a default handler.


Here are separated patches:
  1 - enable OS_MCA for errors other than TLB errors
  2 - OS_MCA handler for memory read recovery
       (well tested on Intel Tiger4.)

I'd also appreciate it if anyone having good test environment
could apply my patch and could report how it works.
(especially reports on non-Tiger/non-Intel platform are welcome.)

Thanks,
H.Seto

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>



--------------020900060904010906070100
Content-Type: text/plain;
 name="patch-268rc3-mcadrv1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-268rc3-mcadrv1"

diff -Nur linux-2.6.8-rc3/arch/ia64/kernel/mca.c linux-2.6.8-rc3-mcadrv-v2/arch/ia64/kernel/mca.c
--- linux-2.6.8-rc3/arch/ia64/kernel/mca.c	2004-08-04 06:27:37.000000000 +0900
+++ linux-2.6.8-rc3-mcadrv-v2/arch/ia64/kernel/mca.c	2004-08-04 18:08:39.000000000 +0900
@@ -828,6 +828,12 @@
 
 }
 
+/* This is a function pointer to other error recovery from MCA */
+int (*ia64_mca_ucmc_other_recover_fp)
+	(void*,ia64_mca_sal_to_os_state_t*,ia64_mca_os_to_sal_state_t*)
+	= NULL;
+EXPORT_SYMBOL(ia64_mca_ucmc_other_recover_fp);
+
 /*
  * ia64_mca_ucmc_handler
  *
@@ -849,11 +855,20 @@
 {
 	pal_processor_state_info_t *psp = (pal_processor_state_info_t *)
 		&ia64_sal_to_os_handoff_state.proc_state_param;
-	int recover = psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc);
+	int recover; 
 
 	/* Get the MCA error record and log it */
 	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA);
 
+	/* No error other than TLB error exist in this SAL error record */
+	recover = (psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc))
+	/* Extra error recovery */
+	   || (ia64_mca_ucmc_other_recover_fp 
+		&& ia64_mca_ucmc_other_recover_fp(
+			IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_MCA),
+			&ia64_sal_to_os_handoff_state,
+			&ia64_os_to_sal_handoff_state)); 
+
 	/*
 	 *  Wakeup all the processors which are spinning in the rendezvous
 	 *  loop.
diff -Nur linux-2.6.8-rc3/include/asm-ia64/mca.h linux-2.6.8-rc3-mcadrv-v2/include/asm-ia64/mca.h
--- linux-2.6.8-rc3/include/asm-ia64/mca.h	2004-08-04 06:27:13.000000000 +0900
+++ linux-2.6.8-rc3-mcadrv-v2/include/asm-ia64/mca.h	2004-08-04 18:08:39.000000000 +0900
@@ -114,6 +114,7 @@
 extern void ia64_monarch_init_handler(void);
 extern void ia64_slave_init_handler(void);
 extern void ia64_mca_cmc_vector_setup(void);
+extern int  (*ia64_mca_ucmc_other_recover_fp)(void *,ia64_mca_sal_to_os_state_t *,ia64_mca_os_to_sal_state_t *);
 
 #endif /* !__ASSEMBLY__ */
 #endif /* _ASM_IA64_MCA_H */

--------------020900060904010906070100--
