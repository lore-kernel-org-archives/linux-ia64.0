From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 22 Feb 2006 02:53:32 +0000
Subject: RE: IA64 non-contiguous memory space bugs
Message-Id: <200602220253.k1M2rWg10346@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20060222001359.GA23574@localhost.localdomain>
References: <20060222001359.GA23574@localhost.localdomain>
In-Reply-To: <20060222001359.GA23574@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'David Gibson' <david@gibson.dropbear.id.au>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

David Gibson wrote on Tuesday, February 21, 2006 4:14 PM
> First bug (confirmed many months ago by Chris Wedgwood) - you can get
> weird effects if you attempt to mmap() something into one of the
> address space gaps.  The ia64 outer wrapper for mmap2() tries to
> prevent it, but doesn't do a good enough job, it's still possible
> indirectly with shmat() and maybe mremap().  Basic trouble is that
> most of the checks applied by the generic code assume that everything
> between 0 and TASK_SIZE is valid.

Ha ha ha.

On ia64, the low level tlb fault handler (vhpt_miss and nested_dtlb_miss)
checks that all unused address bits (between REGION_NUMBER and PGDIR_SHIFT)
should be all zero.  If they are not zero, it will fall into page fault
handler and in there, ia64 should just send SEGV instead of happily hand
over a page.  Buggy buggy....

- Ken

