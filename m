From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 15 Mar 2005 04:44:10 +0000
Subject: Export pda_percpu?
Message-Id: <Pine.LNX.4.58.0503142038340.16107@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In order for mmtimer to properly build as a module, it seems that we need
access to the pda structure. This has been discussed before
http://www.mail-archive.com/linux-ia64@vger.kernel.org/msg00472.html
and was rejected. What else can I do? Define functions as suggested? Do
these exist somewhere?

The mmtimer driver needs to muck around with pretty low level things in order
to program the timer registers correctly.

Index: linux-2.6.11/arch/ia64/sn/kernel/setup.c
=================================--- linux-2.6.11.orig/arch/ia64/sn/kernel/setup.c	2005-03-14 20:25:43.000000000 -0800
+++ linux-2.6.11/arch/ia64/sn/kernel/setup.c	2005-03-14 20:31:49.000000000 -0800
@@ -54,6 +54,9 @@

 DEFINE_PER_CPU(struct pda_s, pda_percpu);

+/* mmtimer needs this to properly function */
+EXPORT_SYMBOL(per_cpu__pda_percpu);
+
 #define MAX_PHYS_MEMORY		(1UL << 49)	/* 1 TB */

 lboard_t *root_lboard[MAX_COMPACT_NODES];
