From: Manfred Spraul <manfreds@colorfullife.com>
Date: Sat, 05 Feb 2000 23:38:21 +0000
Subject: [Linux-ia64] Q: TLB flush under SMP
Message-Id: <marc-linux-ia64-105590678204914@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is the first snapshot supposed to run on SMP hardware/simulator? There
were subtle race on i386 if the tlb flush IPI arrived between
switch_mm() [changes %cr3] and switch_to() [change current], and now I'm
verifying the other SMP capable ports.

On ia64, flush_tlb_range() does nothing if the target mm is not the
active mm on the current processor, but what if that mm is active on
another cpu?

And it seems that the ia64 supports inter processor tlb flushes with
special instructions [ptc.g], is the documentation publicly available? 

And where does the context id come from for "ptc.g"?

TIA,
	Manfred

Btw, please add version numbers to the name of the diff file - at least
the target kernel.



