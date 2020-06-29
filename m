From: Mike Rapoport <rppt@kernel.org>
Date: Mon, 29 Jun 2020 15:59:20 +0000
Subject: Re: [PATCH 4/8] asm-generic: pgalloc: provide generic pmd_alloc_one() and pmd_free_one()
Message-Id: <20200629155920.GD1492837@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200627143453.31835-1-rppt@kernel.org>
 <20200627143453.31835-5-rppt@kernel.org>
 <20200627190304.GG25039@casper.infradead.org>
In-Reply-To: <20200627190304.GG25039@casper.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Satheesh Rajendran <sathnaga@linux.vnet.ibm.com>, linux-csky@vger.kernel.org, sparclinux@vger.kernel.org, linux-riscv@lists.infradead.org, linux-arch@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, linux-hexagon@vger.kernel.org, Joerg Roedel <joro@8bytes.org>, Mike Rapoport <rppt@linux.ibm.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, linux-snps-arc@lists.infradead.org, linux-xtensa@linux-xtensa.org, Arnd Bergmann <arnd@arndb.de>, linux-s390@vger.kernel.org, linux-um@lists.infradead.org, Steven Rostedt <rostedt@goodmis.org>, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, Andy Lutomirski <luto@kernel.org>, Stafford Horne <shorne@gmail.com>, linux-arm-kernel@lists.infradead.org, linux-pari

On Sat, Jun 27, 2020 at 08:03:04PM +0100, Matthew Wilcox wrote:
> On Sat, Jun 27, 2020 at 05:34:49PM +0300, Mike Rapoport wrote:
> > More elaborate versions on arm64 and x86 account memory for the user page
> > tables and call to pgtable_pmd_page_ctor() as the part of PMD page
> > initialization.
> > 
> > Move the arm64 version to include/asm-generic/pgalloc.h and use the generic
> > version on several architectures.
> > 
> > The pgtable_pmd_page_ctor() is a NOP when ARCH_ENABLE_SPLIT_PMD_PTLOCK is
> > not enabled, so there is no functional change for most architectures except
> > of the addition of __GFP_ACCOUNT for allocation of user page tables.
> 
> Thanks for including this line; it reminded me that we're not setting
> the PageTable flag on the page, nor accounting it to the zone page stats.
> Hope you don't mind me tagging a patch to do that on as 9/8.

We also never set PageTable flag for early page tables and for the page
tables allocated directly with get_free_page(), e.g PTI, KASAN.

> We could also do with a pud_page_[cd]tor and maybe even p4d/pgd versions.
> But that brings me to the next question -- could/should some of this
> be moved over to asm-generic/pgalloc.h?  The ctor/dtor aren't called
> from anywhere else, and there's value to reducing the total amount of
> code in mm.h, but then there's also value to keeping all the ifdef
> ARCH_ENABLE_SPLIT_PMD_PTLOCK code together too.  So I'm a bit torn.
> What do you think?

-- 
Sincerely yours,
Mike.
