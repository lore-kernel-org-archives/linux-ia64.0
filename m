From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Thu, 12 Sep 2019 12:21:13 +0000
Subject: Re: [PATCH V2 2/2] mm/pgtable/debug: Add test validating architecture page table helpers
Message-Id: <0116e7b7-cee5-c821-cc54-f4e397c774b2@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1568268173-31302-1-git-send-email-anshuman.khandual@arm.com>
 <1568268173-31302-3-git-send-email-anshuman.khandual@arm.com>
 <20190912110016.srrydg2krplscbgq@box>
In-Reply-To: <20190912110016.srrydg2krplscbgq@box>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



On 09/12/2019 04:30 PM, Kirill A. Shutemov wrote:
> On Thu, Sep 12, 2019 at 11:32:53AM +0530, Anshuman Khandual wrote:
>> +MODULE_LICENSE("GPL v2");
>> +MODULE_AUTHOR("Anshuman Khandual <anshuman.khandual@arm.com>");
>> +MODULE_DESCRIPTION("Test architecture page table helpers");
> 
> It's not module. Why?

Not any more. Nothing in particular. Just that module_init() code gets
executed after page allocator init which is needed here. But I guess
probably not a great way to get this test started.

> 
> BTW, I think we should make all code here __init (or it's variants) so it
> can be discarded on boot. It has not use after that.

Sounds good, will change. Will mark all these functions as __init and
will trigger the test with late_initcall().
