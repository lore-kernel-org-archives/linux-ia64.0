From: Jack Steiner <steiner@sgi.com>
Date: Mon, 26 Feb 2001 15:21:47 +0000
Subject: Re: [Linux-ia64] 2.4.1 + 010131 patch: sys_nanosleep sleeps... infinitely!
Message-Id: <marc-linux-ia64-105590693005204@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005202@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005202@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We have also been seeing hangs running with the latest BIOS. The problem
was isolated to a tiny window in arch/ia64/kernel/time.c where
itm could get loaded with a value that is in the past.
The problems occurs more frequently in recent BIOSs. I saw a reference
to use of PMI interrupts by the new BIOS but am not certain.

We see frequent hangs. Somes it is a hard hang but more often, the
system runs almost OK but any "sleep()" will fail. Also, time stop
advancing for obvious reasons.


I dont know if this could be related to what you see but it is worth a shot....




--- /home/steiner/WA/work240-trillian/linux/arch/ia64/kernel/time.c     Wed Jan 31 13:29:32 2001
+++ arch/ia64/kernel/time.c     Thu Feb  8 12:14:44 2001
@@ -188,10 +250,21 @@
         * because that would force us to call do_timer() which in
         * turn would let our clock run too fast (with the potentially
         * devastating effect of losing monotony of time).
+        *
+        * Note: there is a tiny window between reading itc &
+        * setting itm. It is possible to take a PMI or MCA in this
+        * window. If that happens, we will lose clock interrupts.
+        * To close the window, after writing itm, we reread itc & verify
+        * that the interrupt is still scheduled for the future.
         */
+again:
        while (!time_after(new_itm, ia64_get_itc() + cpu_data[cpu].itm_delta/2))
                new_itm += cpu_data[cpu].itm_delta;
        ia64_set_itm(new_itm);
+
+       if (new_itm <= ia64_get_itc())
+               goto again;
+
 }



-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


