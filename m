From: William Lee Irwin III <wli@holomorphy.com>
Date: Mon, 16 Aug 2004 14:39:03 +0000
Subject: Re: page fault fastpath: Increasing SMP scalability by introducing pte locks?
Message-Id: <20040816143903.GY11200@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408150630560.324@schroedinger.engr.sgi.com> <20040815130919.44769735.davem@redhat.com> <Pine.LNX.4.58.0408151552280.3370@schroedinger.engr.sgi.com> <20040815165827.0c0c8844.davem@redhat.com> <Pine.LNX.4.58.0408151703580.3751@schroedinger.engr.sgi.com> <20040815185644.24ecb247.davem@redhat.com> <Pine.LNX.4.58.0408151924250.4480@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0408151924250.4480@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: "David S. Miller" <davem@redhat.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, 15 Aug 2004, David S. Miller wrote:
>> munmap() can destroy pmd and pte tables.  somehow we have
>> to protect against that, and currently that is having the
>> VMA semaphore held for reading, see free_pgtables().

On Sun, Aug 15, 2004 at 08:29:11PM -0700, Christoph Lameter wrote:
> It looks to me like the code takes care to provide the correct
> sequencing so that the integrity of pgd,pmd and pte links is
> guaranteed from the viewpoint of the MMU in the CPUs. munmap is there to
> protect one kernel thread messing with the addresses of these entities
> that might be stored in another threads register.
> Therefore it is safe to walk the chain only holding the semaphore read
> lock?

Detached pagetables are assumed to be freeable after a TLB flush IPI.
Previously holding ->page_table_lock would prevent the shootdowns of
links to the pagetable page from executing concurrently with
modifications to the pagetable page. Disabling interrupts or otherwise
inhibiting the progress of the IPI'ing cpu is needed to prevent
dereferencing freed pagetables and incorrect accounting based on
contents of about-to-be-freed pagetables. Reference counting pagetable
pages may help here, where the final put would be responsible for
unaccounting the various things in the pagetable page.


-- wli
