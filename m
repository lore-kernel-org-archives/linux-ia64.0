From: David Miller <davem@davemloft.net>
Date: Fri, 12 Oct 2018 18:02:20 +0000
Subject: Re: [PATCH v2 2/2] mm: speed up mremap by 500x on large regions
Message-Id: <20181012.110220.321284613911888246.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181012013756.11285-1-joel@joelfernandes.org>
        <20181012013756.11285-2-joel@joelfernandes.org>
        <20181012113056.gxhcbrqyu7k7xnyv@kshutemo-mobl1>
In-Reply-To: <20181012113056.gxhcbrqyu7k7xnyv@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kirill@shutemov.name
Cc: joel@joelfernandes.org, linux-kernel@vger.kernel.org, kernel-team@android.com, minchan@kernel.org, pantin@google.com, hughd@google.com, lokeshgidra@google.com, dancol@google.com, mhocko@kernel.org, akpm@linux-foundation.org, aryabinin@virtuozzo.com, luto@kernel.org, bp@alien8.de, catalin.marinas@arm.com, chris@zankel.net, dave.hansen@linux.intel.com, elfring@users.sourceforge.net, fenghua.yu@intel.com, geert@linux-m68k.org, gxt@pku.edu.cn, deller@gmx.de, mingo@redhat.com, jejb@parisc-linux.org, jdike@addtoit.com, jonas@southpole.se, Julia.Lawall@lip6.fr, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, lftan@altera.com, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linu

From: "Kirill A. Shutemov" <kirill@shutemov.name>
Date: Fri, 12 Oct 2018 14:30:56 +0300

> I looked into the code more and noticed move_pte() helper called from
> move_ptes(). It changes PTE entry to suite new address.
> 
> It is only defined in non-trivial way on Sparc. I don't know much about
> Sparc and it's hard for me to say if the optimization will break anything
> there.
> 
> I think it worth to disable the optimization if __HAVE_ARCH_MOVE_PTE is
> defined. Or make architectures state explicitely that the optimization is
> safe.

What sparc is doing in move_pte() is flushing the data-cache
(synchronously) if the virtual address color of the mapping changes.

Hope this helps.
