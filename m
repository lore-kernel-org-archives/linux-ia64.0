From: Stephan.Zeisset@intel.com
Date: Thu, 31 Aug 2000 18:40:22 +0000
Subject: RE: [Linux-ia64] SMP TLB flushes
Message-Id: <marc-linux-ia64-105590678205429@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205428@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205428@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

As for the ptc.g, the region id comes from the region register that
is selected through bits [63:61] of the address.

-----Original Message-----
From: Manfred Spraul [mailto:manfred@colorfullife.com]
Sent: Thursday, August 31, 2000 10:57 AM
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] SMP TLB flushes


Is it correct that the SMP part of the SMP flushing code is still
missing? I'm just noisy and I don't understand yet how the ia64 cpu is
supposed to perform tlb flushes.

* ptc.g only gets the address and the size as parameters, but not a
region id. What if cpu 1 (running kswapd, arbitrary thread context)
wants to flush a page from another thread, and that thread is running on
cpu 2?

* could you add a big warning to start_lazy_tlb [kernel/exit.c] that the
function is unsafe?
Both ppc and ia64 scan the task list and assume that they can find each
mm_struct. If someone actually uses start_lazy_tlb, then that would be
incorrect.

Btw, the i386 tlb flush contained a single instruction race (read x,
write y instead of write y, read x) and this was enough for corruptions
- I overlooked one problem with concurrent tlb flushes and thread
switches.

Please cc me, I'm not subscribed to the list.

--
	Manfred

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


