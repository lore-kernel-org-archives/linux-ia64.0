From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Tue, 12 Nov 2019 06:52:52 +0000
Subject: Re: [PATCH V9] mm/debug: Add tests validating architecture page table helpers
Message-Id: <fe6b8140-1017-d081-570c-62213fe39624@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1573532326-24084-1-git-send-email-anshuman.khandual@arm.com>
 <20191112062951.GA100264@gmail.com>
In-Reply-To: <20191112062951.GA100264@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



On 11/12/2019 11:59 AM, Ingo Molnar wrote:
> 
> * Anshuman Khandual <anshuman.khandual@arm.com> wrote:
> 
>> +config DEBUG_VM_PGTABLE
>> +	bool "Debug arch page table for semantics compliance"
>> +	depends on MMU
>> +	depends on DEBUG_VM
>> +	depends on ARCH_HAS_DEBUG_VM_PGTABLE
>> +	help
>> +	  This option provides a debug method which can be used to test
>> +	  architecture page table helper functions on various platforms in
>> +	  verifying if they comply with expected generic MM semantics. This
>> +	  will help architecture code in making sure that any changes or
>> +	  new additions of these helpers still conform to expected
>> +	  semantics of the generic MM.
>> +
>> +	  If unsure, say N.
> 
> Since CONFIG_DEBUG_VM is generally disabled in distro kernel packages, 
> why not make this 'default y' to maximize testing coverage? The code size 
> increase should be minimal, and DEBUG_VM increases size anyway.

Sure, will do.

> 
> Other than that this looks good to me:
> 
>   Reviewed-by: Ingo Molnar <mingo@kernel.org>

Thank you.

> 
> Thanks,
> 
> 	Ingo
> 
