From: Arun Sharma <arun.sharma@intel.com>
Date: Wed, 16 Apr 2003 21:00:13 +0000
Subject: [Linux-ia64] brl emulation bug fix
Message-Id: <marc-linux-ia64-105590723705514@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This applies to both 2.4 and 2.5. A 64 bit value was being assigned to
an int.

	-Arun

--- arch/ia64/kernel/brl_emu.c.orig     Thu Oct 17 10:02:52 2002
+++ arch/ia64/kernel/brl_emu.c  Thu Oct 17 15:40:29 2002
@@ -59,7 +59,7 @@
        unsigned long next_ip;
        struct siginfo siginfo;
        struct illegal_op_return rv;
-       int tmp_taken, unimplemented_address;
+       long tmp_taken, unimplemented_address;

        rv.fkt = (unsigned long) -1;


