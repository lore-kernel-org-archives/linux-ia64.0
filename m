From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 25 May 2022 11:10:17 +0000
Subject: Re: [PATCH v3] mm: Avoid unnecessary page fault retires on shared memory types
Message-Id: <Yo4OmaNW5YUrGE0S@hirez.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220524234531.1949-1-peterx@redhat.com>
In-Reply-To: <20220524234531.1949-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Xu <peterx@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Richard Henderson <rth@twiddle.net>, David Hildenbrand <david@redhat.com>, Matt Turner <mattst88@gmail.com>, Albert Ou <aou@eecs.berkeley.edu>, Michal Simek <monstr@monstr.eu>, Russell King <linux@armlinux.org.uk>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, linux-riscv@lists.infradead.org, Alexander Gordeev <agordeev@linux.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonas Bonn <jonas@southpole.se>, Will Deacon <will@kernel.org>, "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>, "H . Peter Anvin" <hpa@zytor.com>, Andrea Arcangeli <aarcange@redhat.com>, openrisc@lists.librecores.org, linux-s390@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, linux-m68k@lists.linux-m68k.org, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <hca@linux.ibm.com>, Chris Zankel <chris@zankel.net>, Alistair Popple <apopple@nvidia.com>, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, sparclinux@vger.kernel.org, Christian Borntraeger <borntraeger@linux.ibm.com>, Stafford Horne <shorne@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Paul Mackerras <paulus@samba.org>, linux-arm-kernel@lists.infradead.org, Sven Schnelle <svens@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-xtensa@linux-xtensa.org, Nicholas Piggin <npiggin@gmail.com>, linux-sh@vger.kernel.org, Vasily Gorbik <gor@linux.ibm.com>, Borislav Petkov <bp@alien8.de>, linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Helge Deller <deller@gmx.de>, Vineet Gupta <vgupta@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Paul Walmsley <paul.walmsley@sifive.com>, Johannes Weiner <hannes@cmpxchg.org>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-um@lists.infradead.org, linux-alpha@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>, linux-ia64@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Dinh Nguyen <dinguyen@kernel.org>, Guo Ren <guoren@kernel.org>, linux-snps-arc@lists.infradead.org, Hugh Dickins <hughd@google.com>, Rich Felker <dalias@libc.org>, Andy Lutomirski <luto@kernel.org>, Richard Weinberger <richard@nod.at>, linuxppc-dev@lists.ozlabs.org, Brian Cain <bcain@quicinc.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Andrew Morton <akpm@linux-foundation.org>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, linux-parisc@vger.kernel.org, "David S . Miller" <davem@davemloft.net>

On Tue, May 24, 2022 at 07:45:31PM -0400, Peter Xu wrote:
> I observed that for each of the shared file-backed page faults, we're very
> likely to retry one more time for the 1st write fault upon no page.  It's
> because we'll need to release the mmap lock for dirty rate limit purpose
> with balance_dirty_pages_ratelimited() (in fault_dirty_shared_page()).
> 
> Then after that throttling we return VM_FAULT_RETRY.
> 
> We did that probably because VM_FAULT_RETRY is the only way we can return
> to the fault handler at that time telling it we've released the mmap lock.
> 
> However that's not ideal because it's very likely the fault does not need
> to be retried at all since the pgtable was well installed before the
> throttling, so the next continuous fault (including taking mmap read lock,
> walk the pgtable, etc.) could be in most cases unnecessary.
> 
> It's not only slowing down page faults for shared file-backed, but also add
> more mmap lock contention which is in most cases not needed at all.
> 
> To observe this, one could try to write to some shmem page and look at
> "pgfault" value in /proc/vmstat, then we should expect 2 counts for each
> shmem write simply because we retried, and vm event "pgfault" will capture
> that.
> 
> To make it more efficient, add a new VM_FAULT_COMPLETED return code just to
> show that we've completed the whole fault and released the lock.  It's also
> a hint that we should very possibly not need another fault immediately on
> this page because we've just completed it.
> 
> This patch provides a ~12% perf boost on my aarch64 test VM with a simple
> program sequentially dirtying 400MB shmem file being mmap()ed and these are
> the time it needs:
> 
>   Before: 650.980 ms (+-1.94%)
>   After:  569.396 ms (+-1.38%)
> 
> I believe it could help more than that.
> 
> We need some special care on GUP and the s390 pgfault handler (for gmap
> code before returning from pgfault), the rest changes in the page fault
> handlers should be relatively straightforward.
> 
> Another thing to mention is that mm_account_fault() does take this new
> fault as a generic fault to be accounted, unlike VM_FAULT_RETRY.
> 
> I explicitly didn't touch hmm_vma_fault() and break_ksm() because they do
> not handle VM_FAULT_RETRY even with existing code, so I'm literally keeping
> them as-is.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
