From: Dave Hansen <dave.hansen@intel.com>
Date: Wed, 04 Sep 2019 23:14:08 +0000
Subject: Re: [PATCH 1/1] mm/pgtable/debug: Add test validating architecture page table helpers
Message-Id: <3b67e4d8-ba67-e7b2-f4d1-1276262d349e@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1567497706-8649-1-git-send-email-anshuman.khandual@arm.com>
 <1567497706-8649-2-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1567497706-8649-2-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-arm-kernel@lists.infradead.org, linux-snps-arc@lists.infradead.org, Kees Cook <keescook@chromium.org>, "Shutemov,
 Kirill" <kirill.shutemov@intel.com>, Mark Brown <broonie@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On 9/3/19 1:01 AM, Anshuman Khandual wrote:
> This adds a test module which will validate architecture page table helpers
> and accessors regarding compliance with generic MM semantics expectations.
> This will help various architectures in validating changes to the existing
> page table helpers or addition of new ones.

This looks really cool.  The "only" complication on x86 is the large
number of compile and runtime options that we have.  When this gets
merged, it would be really nice to make sure that the 0day guys have
good coverage of all the configurations.

I'm not _quite_ sure what kind of bugs it will catch on x86 and I
suspect it'll have more value for the other architectures, but it seems
harmless enough.
