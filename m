From: Peter Xu <peterx@redhat.com>
Date: Mon, 30 May 2022 15:52:54 +0000
Subject: Re: [PATCH v4] mm: Avoid unnecessary page fault retires on shared memory types
Message-Id: <YpToVpjXmdFqGOpY@xz-m1.local>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220527193936.30678-1-peterx@redhat.com>
 <YpPYkzbrQmy4FjrI@osiris>
 <33fd4731-9765-d78b-bdc3-f8243c98e81f@linux.ibm.com>
In-Reply-To: <33fd4731-9765-d78b-bdc3-f8243c98e81f@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christian Borntraeger <borntraeger@linux.ibm.com>
Cc: Heiko Carstens <hca@linux.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Will Deacon <will@kernel.org>, Matt Turner <mattst88@gmail.com>, linux-s390@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Brian Cain <bcain@quicinc.com>, Borislav Petkov <bp@alien8.de>, linux-alpha@vger.kernel.org, Alistair Popple <apopple@nvidia.com>, Jonas Bonn <jonas@southpole.se>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, linux-snps-arc@lists.infradead.org, Vineet Gupta <vgupta@kernel.org>, Vasily Gorbik <gor@linux.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Rich Felker <dalias@libc.org>, sparclinux@vger.kernel.org, Russell King <linux@armlinux.org.uk>, David Hildenbrand <david@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nicholas Piggin <npiggin@gmail.com>, "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>, linux-xtensa@linux-xtensa.org, linux-sh@vger.kernel.org, Paul Walmsley <paul.walmsley@sifive.com>, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, Richard Henderson <rth@twiddle.net>, Guo Ren <guoren@kernel.org>, linux-parisc@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Helge Deller <deller@gmx.de>, Al Viro <viro@zeniv.linux.org.uk>, Albert Ou <aou@eecs.berkeley.edu>, linux-um@lists.infradead.org, "H . Peter Anvin" <hpa@zytor.com>, Janosch Frank <frankja@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, openrisc@lists.librecores.org, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, linux-hexagon@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Stafford Horne <shorne@gmail.com>, linux-csky@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mips@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Alexander Gordeev <agordeev@linux.ibm.com>, Dinh Nguyen <dinguyen@kernel.org>, Palmer Dabbelt <palmer@dabbelt.com>, "David S . Miller" <davem@davemloft.net>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-riscv@lists.infradead.org, Max Filippov <jcmvbkbc@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Johannes Berg <johannes@sipsolutions.net>, Chris Zankel <chris@zankel.net>, Michal Simek <monstr@monstr.eu>, x86@kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Dave Hansen <dave.hansen@linux.intel.com>, Richard Weinberger <richard@nod.at>, Ingo Molnar <mingo@kernel.org>

On Mon, May 30, 2022 at 11:35:10AM +0200, Christian Borntraeger wrote:
> 
> 
> Am 29.05.22 um 22:33 schrieb Heiko Carstens:
> [...]
> > 
> > Guess the patch below on top of your patch is what we want.
> > Just for clarification: if gmap is not NULL then the process is a kvm
> > process. So, depending on the workload, this optimization makes sense.
> > 
> > diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
> > index 4608cc962ecf..e1d40ca341b7 100644
> > --- a/arch/s390/mm/fault.c
> > +++ b/arch/s390/mm/fault.c
> > @@ -436,12 +436,11 @@ static inline vm_fault_t do_exception(struct pt_regs *regs, int access)
> >   	/* The fault is fully completed (including releasing mmap lock) */
> >   	if (fault & VM_FAULT_COMPLETED) {
> > -		/*
> > -		 * Gmap will need the mmap lock again, so retake it.  TODO:
> > -		 * only conditionally take the lock when CONFIG_PGSTE set.
> > -		 */
> > -		mmap_read_lock(mm);
> > -		goto out_gmap;
> > +		if (gmap) {
> > +			mmap_read_lock(mm);
> > +			goto out_gmap;
> > +		}
> > +		goto out;
> 
> Yes, that makes sense. With that
> 
> Acked-by: Christian Borntraeger <borntraeger@linux.ibm.com>

Looks sane, thanks Heiko, Christian.  I'll cook another one.

-- 
Peter Xu
