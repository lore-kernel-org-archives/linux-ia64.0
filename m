From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 02 Aug 2007 05:38:39 +0000
Subject: RE: ia64 mmu_gather question
Message-Id: <617E1C2C70743745A92448908E030B2A0211ADDF@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186026055.5495.585.camel@localhost.localdomain>
In-Reply-To: <1186026055.5495.585.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Answers to select questions (that I can do off the top of my head).

> In addition, however, I do have a question. I haven't tracked every bit
> of MM code in ia64 land yet and I'm wondering how are the page table
> translations faulted in ? via a SW miss handler ? Or some HW handler ?

The page tables translations are inserted in s/w (by the VHPT miss handler
in arch/ia64/kernel/ivt.S).  Essentially the first TLB miss in a PMD range
will end up here and will insert both the page mapping that we actually
want, plus the mapping for the page table (so that a subsequent TLB miss on
this address, or another address in the PMD range) can be serviced by the
h/w VHPT walker (for as long as the page table mapping survives in the
TLB).

> Is there some locking ?
No locking.  But we do have race detection.  After we chase the PGD>PUD>PMD>PTE
pointers we insert the TLB entry.  Then we retrace the pointer chain and
make sure that the pte we find is still the same.  If it isn't, then we
purge the entry we just inserted and go for a full page fault.

Time to tell bed-time stories to my daughter.  More tomorrow (if someone
else doesn't fill in the rest of the answers before I get back to this).

-Tony
