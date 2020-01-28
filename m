From: Qian Cai <cai@lca.pw>
Date: Tue, 28 Jan 2020 05:48:30 +0000
Subject: Re: [PATCH V12] mm/debug: Add tests validating architecture page table helpers
Message-Id: <EE5B936C-121E-4322-A285-603D82D59B3A@lca.pw>
List-Id: <linux-ia64.vger.kernel.org>
References: <012158b7-a40e-050f-cd1b-d6ce7faf042f@arm.com>
In-Reply-To: <012158b7-a40e-050f-cd1b-d6ce7faf042f@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Anshuman Khandual <Anshuman.Khandual@arm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



> On Jan 27, 2020, at 11:58 PM, Anshuman Khandual <Anshuman.Khandual@arm.com> wrote:
> 
> As I had mentioned before, the test attempts to formalize page table helper semantics
> as expected from generic MM code paths and intend to catch deviations when enabled on
> a given platform. How else should we test semantics errors otherwise ? There are past
> examples of usefulness for this procedure on arm64 and on s390. I am wondering how
> else to prove the usefulness of a debug feature if these references are not enough.

Not saying it will not be useful. As you mentioned it actually found a bug or two in the past. The problem is that there is always a cost to maintain something like this, and nobody knew how things could be broken even for the isolated code you mentioned in the future given how complicated the kernel code base is. I am not so positive that many developers would enable this debug feature and use it on a regular basis from the information you gave so far. 

On the other hand, it might just be good at maintaining this thing out of tree by yourself anyway, because if there isn’t going to be used by many developers, few people is going to contribute to this and even noticed when it is broken. What’s the point of getting this merged apart from being getting some meaningless credits?
