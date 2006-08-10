From: Francois WELLENREITER <francois.wellenreiter@bull.net>
Date: Thu, 10 Aug 2006 09:27:02 +0000
Subject: MCA/INIT debug trace
Message-Id: <44DAFBE6.4030701@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



                      Hi Keith and all,


          a few days ago, I have tried to debug some deadlock problems
occurring on an IA-64 machine using INIT signal.
I have noticed that only the blocked process backtraces are shown on the
console screen
and the general registers are not displayed anymore.
To improve it, could it be possible to integrate the following patch
here below ?
I have just added a call to "show_regs" in
"ia64_mca_modify_original_stack" function.

Regards,
                                           Francois


___________________________________________

--- linux-2.6.17.6/arch/ia64/kernel/mca.c~    2006-08-08
17:42:44.000000000 +0200
+++ linux-2.6.17.6/arch/ia64/kernel/mca.c    2006-08-10
10:40:31.000000000 +0200
@@ -957,6 +957,9 @@
     old_sw->ar_rnat = old_rnat;
 
     sos->prev_task = previous_current;
+
+    show_regs(&old_regs);
+
     return previous_current;
 
 no_mod:

