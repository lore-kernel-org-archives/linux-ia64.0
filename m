From: Peter Xu <peterx@redhat.com>
Date: Fri, 27 May 2022 14:53:36 +0000
Subject: Re: [PATCH v3] mm: Avoid unnecessary page fault retires on shared memory types
Message-Id: <YpDl8IM0FF6GeJ4B@xz-m1.local>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220524234531.1949-1-peterx@redhat.com>
 <YpCsBwFArieTpvg2@gmail.com>
In-Reply-To: <YpCsBwFArieTpvg2@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Richard Henderson <rth@twiddle.net>, David Hildenbrand <david@redhat.com>, Matt Turner <mattst88@gmail.com>, Albert Ou <aou@eecs.berkeley.edu>, Michal Simek <monstr@monstr.eu>, Russell King <linux@armlinux.org.uk>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, linux-riscv@lists.infradead.org, Alexander Gordeev <agordeev@linux.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonas Bonn <jonas@southpole.se>, Will Deacon <will@kernel.org>, "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>, "H . Peter Anvin" <hpa@zytor.com>, Andrea Arcangeli <aarcange@redhat.com>, openrisc@lists.librecores.org, linux-s390@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, linux-m68k@lists.linux-m68k.org, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, Chris Zankel <chris@zankel.net>, Peter Zijlstra <peterz@infradead.org>, Alistair Popple <apopple@nvidia.com>, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, sparclinux@vger.kernel.org, Christian Borntraeger <borntraeger@linux.ibm.com>, Stafford Horne <shorne@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Paul Mackerras <paulus@samba.org>, linux-arm-kernel@lists.infradead.org, Sven Schnelle <svens@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-xtensa@linux-xtensa.org, Nicholas Piggin <npiggin@gmail.com>, linux-sh@vger.kernel.org, Vasily Gorbik <gor@linux.ibm.com>, Borislav Petkov <bp@alien8.de>, linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Helge Deller <deller@gmx.de>, Vineet Gupta <vgupta@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Paul Walmsley <paul.walmsley@sifive.com>, Johannes Weiner <hannes@cmpxchg.org>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-um@lists.infradead.org, linux-alpha@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>, linux-ia64@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Dinh Nguyen <dinguyen@kernel.org>, Guo Ren <guoren@kernel.org>, linux-snps-arc@lists.infradead.org, Hugh Dickins <hughd@google.com>, Rich Felker <dalias@libc.org>, Andy Lutomirski <luto@kernel.org>, Richard Weinberger <richard@nod.at>, linuxppc-dev@lists.ozlabs.org, Brian Cain <bcain@quicinc.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Andrew Morton <akpm@linux-foundation.org>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, linux-parisc@vger.kernel.org, "David S . Miller" <davem@davemloft.net>

On Fri, May 27, 2022 at 12:46:31PM +0200, Ingo Molnar wrote:
> 
> * Peter Xu <peterx@redhat.com> wrote:
> 
> > This patch provides a ~12% perf boost on my aarch64 test VM with a simple
> > program sequentially dirtying 400MB shmem file being mmap()ed and these are
> > the time it needs:
> >
> >   Before: 650.980 ms (+-1.94%)
> >   After:  569.396 ms (+-1.38%)
> 
> Nice!
> 
> >  arch/x86/mm/fault.c           |  4 ++++
> 
> Reviewed-by: Ingo Molnar <mingo@kernel.org>
> 
> Minor comment typo:
> 
> > +		/*
> > +		 * We should do the same as VM_FAULT_RETRY, but let's not
> > +		 * return -EBUSY since that's not reflecting the reality on
> > +		 * what has happened - we've just fully completed a page
> > +		 * fault, with the mmap lock released.  Use -EAGAIN to show
> > +		 * that we want to take the mmap lock _again_.
> > +		 */
> 
> s/reflecting the reality on what has happened
>  /reflecting the reality of what has happened

Will fix.

> 
> >  	ret = handle_mm_fault(vma, address, fault_flags, NULL);
> > +
> > +	if (ret & VM_FAULT_COMPLETED) {
> > +		/*
> > +		 * NOTE: it's a pity that we need to retake the lock here
> > +		 * to pair with the unlock() in the callers. Ideally we
> > +		 * could tell the callers so they do not need to unlock.
> > +		 */
> > +		mmap_read_lock(mm);
> > +		*unlocked = true;
> > +		return 0;
> 
> Indeed that's a pity - I guess more performance could be gained here, 
> especially in highly parallel threaded workloads?

Yes I think so.

The patch avoids the page fault retry, including the mmap lock/unlock side.
Now if we retake the lock for fixup_user_fault() we still safe time for
pgtable walks but the lock overhead will be somehow kept, just with smaller
critical sections.

Some fixup_user_fault() callers won't be affected as long as unlocked=NULL
is passed - e.g. the futex code path (fault_in_user_writeable).  After all
they never needed to retake the lock before/after this patch.

It's about the other callers, and they may need some more touch-ups case by
case.  Examples are follow_fault_pfn() in vfio and hva_to_pfn_remapped() in
KVM: both of them returns -EAGAIN when *unlocked=true.  We need to teach
them to know "*unlocked=true" does not necessarily mean a retry attempt.

I think I can look into them if this patch can be accepted as a follow up.

Thanks for taking a look!

-- 
Peter Xu
