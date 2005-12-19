From: Robin Holt <holt@sgi.com>
Date: Mon, 19 Dec 2005 21:52:08 +0000
Subject: Workaround genksyms not handling an EXPORT_SYMBOL() on a struct nodepda_s *.
Message-Id: <20051219215208.GB25888@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

The following works around a problem in genksyms.  I do not understand
flex and bison.  For the short term, I was wondering if the following
patch would be acceptable.  I would hope it is not a final solution,
but it at least generates a CRC for __sn_nodepda.

Thanks,
Robin


Index: linux-2.6/arch/ia64/sn/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/setup.c	2005-12-13 02:30:25.579260799 -0600
+++ linux-2.6/arch/ia64/sn/kernel/setup.c	2005-12-19 15:02:09.574333683 -0600
@@ -77,7 +77,9 @@ EXPORT_PER_CPU_SYMBOL(__sn_hub_info);
 DEFINE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_NUMNODES]);
 EXPORT_PER_CPU_SYMBOL(__sn_cnodeid_to_nasid);
 
-DEFINE_PER_CPU(struct nodepda_s *, __sn_nodepda);
+/* Really ugly hack to get genksyms to produce a CRC value. */
+typedef struct nodepda_s * nodepda_s_p;
+DEFINE_PER_CPU(nodepda_s_p, __sn_nodepda);
 EXPORT_PER_CPU_SYMBOL(__sn_nodepda);
 
 char sn_system_serial_number_string[128];
