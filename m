From: Qian Cai <cai@lca.pw>
Date: Thu, 24 Oct 2019 16:51:57 +0000
Subject: Re: [PATCH V7] mm/debug: Add tests validating architecture page table helpers
Message-Id: <FCAFFD72-3781-4474-8393-A4E40264473A@lca.pw>
List-Id: <linux-ia64.vger.kernel.org>
References: <1571625739-29943-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1571625739-29943-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <Anshuman.Khandual@arm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>, Mike Kravetz <mike.kravetz@oracle.com>



> On Oct 24, 2019, at 10:50 AM, Anshuman Khandual <Anshuman.Khandual@arm.com> wrote:
> 
> Changes in V7:
> 
> - Memory allocation and free routines for mapped pages have been droped
> - Mapped pfns are derived from standard kernel text symbol per Matthew
> - Moved debug_vm_pgtaable() after page_alloc_init_late() per Michal and Qian 
> - Updated the commit message per Michal
> - Updated W=1 GCC warning problem on x86 per Qian Cai

It would be interesting to know if you actually tested  out to see if the warning went away. As far I can tell, the GCC is quite stubborn there, so I am not going to insist.
