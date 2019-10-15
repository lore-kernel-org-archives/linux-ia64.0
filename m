From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Tue, 15 Oct 2019 15:33:11 +0000
Subject: Re: [PATCH V6 0/2] mm/debug: Add tests validating architecture page table helpers
Message-Id: <c052784a-a5d7-878e-cd97-01daa90c0ed8@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1571131302-32290-1-git-send-email-anshuman.khandual@arm.com>
 <1571150502.5937.39.camel@lca.pw>
In-Reply-To: <1571150502.5937.39.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Qian Cai <cai@lca.pw>, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>, Mike Kravetz <mike.kravetz@oracle.com>



On 10/15/2019 08:11 PM, Qian Cai wrote:
> The x86 will crash with linux-next during boot due to this series (v5) with the
> config below plus CONFIG_DEBUG_VM_PGTABLE=y. I am not sure if v6 would address
> it.
> 
> https://raw.githubusercontent.com/cailca/linux-mm/master/x86.config
> 
> [   33.862600][    T1] page:ffffea0009000000 is uninitialized and poisoned
> [   33.862608][    T1] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff
> ffffff871140][    T1]  ? _raw_spin_unlock_irq+0x27/0x40
> [   33.871140][    T1]  ? rest_init+0x307/0x307
> [   33.871140][    T1]  kernel_init+0x11/0x139
> [   33.871140][    T1]  ? rest_init+0x307/0x307
> [   33.871140][    T1]  ret_from_fork+0x27/0x50
> [   33.871140][    T1] Modules linked in:
> [   33.871140][    T1] ---[ end trace e99d392b0f7befbd ]---
> [   33.871140][    T1] RIP: 0010:alloc_gigantic_page_order+0x3fe/0x490

Hmm, with defconfig (DEBUG_VM=y and DEBUG_VM_PGTABLE=y) it does not crash but
with the config above, it does. Just wondering if it is possible that these
pages might not been initialized yet because DEFERRED_STRUCT_PAGE_INIT=y ?

[   13.898549][    T1] page:ffffea0005000000 is uninitialized and poisoned
[   13.898549][    T1] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
[   13.898549][    T1] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
[   13.898549][    T1] page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
[   13.898549][    T1] ------------[ cut here ]------------
[   13.898549][    T1] kernel BUG at ./include/linux/mm.h:1107!
[   13.898549][    T1] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
[   13.898549][    T1] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 5.4.0-rc3-next-20191015+ #
