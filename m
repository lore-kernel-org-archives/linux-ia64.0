From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Thu, 26 May 2005 02:04:25 +0000
Subject: [PATCH RESENT] fix HP simulator smp build replace __devinit -> __devinitdata (revised)
Message-Id: <20050526020425.GB18669@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony
  I sent this patch in about a month ago, I just check the Ia64 Git logs
and did not see it there so I'm re-sending it.

Revised patch, thanks Keith
Tested for compile and boot on zx1 and simulator.

Signed-off-by:  Darren Williams <dsw@gelato.unsw.edu.au>

--- linux-2.6-orig/arch/ia64/kernel/smpboot.c   2005-05-09 16:29:30.000000000 +1000
+++ linux-2.6-import/arch/ia64/kernel/smpboot.c 2005-05-09 21:03:47.000000000 +1000
@@ -624,7 +624,7 @@
        __u16   thread_id;
        __u16   proc_fixed_addr;
        __u8    valid;
-}mt_info[NR_CPUS] __devinit;
+}mt_info[NR_CPUS] __devinitdata;

 #ifdef CONFIG_HOTPLUG_CPU
 static inline void


 - dsw 

--------------------------------------------------
Darren Williams <dsw AT gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
