From: Catalin Marinas <catalin.marinas@arm.com>
Date: Mon, 30 May 2022 13:31:52 +0000
Subject: Re: [PATCH v4] mm: Avoid unnecessary page fault retires on shared memory types
Message-Id: <YpTHSNQxzQxwJ4vQ@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220527193936.30678-1-peterx@redhat.com>
In-Reply-To: <20220527193936.30678-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Xu <peterx@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Will Deacon <will@kernel.org>, Matt Turner <mattst88@gmail.com>, linux-s390@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Brian Cain <bcain@quicinc.com>, Borislav Petkov <bp@alien8.de>, linux-alpha@vger.kernel.org, Alistair Popple <apopple@nvidia.com>, Jonas Bonn <jonas@southpole.se>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, linux-snps-arc@lists.infradead.org, Vineet Gupta <vgupta@kernel.org>, Vasily Gorbik <gor@linux.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Rich Felker <dalias@libc.org>, sparclinux@vger.kernel.org, Russell King <linux@armlinux.org.uk>, David Hildenbrand <david@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nicholas Piggin <npiggin@gmail.com>, "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>, linux-xtensa@linux-xtensa.org, linux-sh@vger.kernel.org, Paul Walmsley <paul.walmsley@sifive.com>, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, Richard Henderson <rth@twiddle.net>, Guo Ren <guoren@kernel.org>, linux-parisc@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Helge Deller <deller@gmx.de>, Al Viro <viro@zeniv.linux.org.uk>, Albert Ou <aou@eecs.berkeley.edu>, linux-um@lists.infradead.org, "H . Peter Anvin" <hpa@zytor.com>, Janosch Frank <frankja@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, openrisc@lists.librecores.org, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, linux-hexagon@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Stafford Horne <shorne@gmail.com>, linux-csky@vger.kernel.org, Heiko Carstens <hca@linux.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mips@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Alexander Gordeev <agordeev@linux.ibm.com>, Dinh Nguyen <dinguyen@kernel.org>, Palmer Dabbelt <palmer@dabbelt.com>, "David S . Miller" <davem@davemloft.net>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-riscv@lists.infradead.org, Max Filippov <jcmvbkbc@gmail.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Christian Borntraeger <borntraeger@linux.ibm.com>, Johannes Berg <johannes@sipsolutions.net>, Chris Zankel <chris@zankel.net>, Michal Simek <monstr@monstr.eu>, x86@kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Dave Hansen <dave.hansen@linux.intel.com>, Richard Weinberger <richard@nod.at>, Ingo Molnar <mingo@kernel.org>

On Fri, May 27, 2022 at 03:39:36PM -0400, Peter Xu wrote:
> diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
> index 77341b160aca..e401d416bbd6 100644
> --- a/arch/arm64/mm/fault.c
> +++ b/arch/arm64/mm/fault.c
> @@ -607,6 +607,10 @@ static int __kprobes do_page_fault(unsigned long far, unsigned int esr,
>  		return 0;
>  	}
>  
> +	/* The fault is fully completed (including releasing mmap lock) */
> +	if (fault & VM_FAULT_COMPLETED)
> +		return 0;
> +
>  	if (fault & VM_FAULT_RETRY) {
>  		mm_flags |= FAULT_FLAG_TRIED;
>  		goto retry;

For arm64:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
