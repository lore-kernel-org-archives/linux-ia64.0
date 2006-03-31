From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 31 Mar 2006 21:51:49 +0000
Subject: RE: accessed/dirty bit handler tuning
Message-Id: <200603312151.k2VLp5g06842@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44157CF1.5060902@bull.net>
In-Reply-To: <44157CF1.5060902@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan Menyhart wrote on Friday, March 31, 2006 1:18 PM
> Problem #1:
> 
> cpu0 keeps (see r17) the physical address of a PTE whose page has gone.
> cpu0 is not sensitive to ptc.g-ing the PTE page address, because it accesses
> the PTE page by use of this (potentially invalid) physical address, not as the
> virtually mapped linear page table.
> 
> cpu0 has not got the right to touch a PTE page unless it makes sure
> that the PTE page is still anchored by its current->mm->pgd...
> 
> Problem #2:
> 
> cpu2 may install the old data page freed by cpu1 at the same PTE offset as it
> was before.
> The new PTE may be numerically the same as the one just inserted by cpu0
> (and it is at the same physical address), but it belongs to another process.
> cpu0 cannot catch the ptc.g for the dirty bit fault address because
> itc.d + srlz.d have not completed by that moment.
> The compare may result in a false positive.
> cpu0 may be granted the write access right to a data page of someone else.

You are correct.  I forgot that nested_dtlb_miss doesn't actually do the check.
I rather prefer not to add anything in the fast path to detect an exceedingly
rare race event (only if ia64 architect screwed up so bad that made itc.d have
10,000 cycle latency and at the same time does a splendid job at job at ptc.g
which completes in zero cycle along with other thousands of other instructions).

In that event, as I said, it's actually better to simple purge the entry, write
the dirty bit into in-memory page table entry and let the hardware page walker
insert the new entry.
