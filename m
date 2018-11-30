From: lijiang <lijiang@redhat.com>
Date: Fri, 30 Nov 2018 04:44:34 +0000
Subject: Re: [PATCH 1/2 v8] resource: add the new I/O resource descriptor 'IORES_DESC_RESERVED'
Message-Id: <5bda3bfe-8ab2-3c3e-fc4d-6322d372e9ae@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181129080956.20776-1-lijiang@redhat.com>
 <20181129080956.20776-2-lijiang@redhat.com>
 <20181130034129.GA26791@dhcp-128-65.nay.redhat.com>
In-Reply-To: <20181130034129.GA26791@dhcp-128-65.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Dave Young <dyoung@redhat.com>
Cc: linux-kernel@vger.kernel.org, kexec@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-efi@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, akpm@linux-foundation.org, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, ard.biesheuvel@linaro.org, tony.luck@intel.com, fenghua.yu@intel.com, bhe@redhat.com

在 2018年11月30日 11:41, Dave Young 写道:
> On 11/29/18 at 04:09pm, Lianbo Jiang wrote:
>> When doing kexec_file_load, the first kernel needs to pass the e820
>> reserved ranges to the second kernel. But kernel can not exactly
>> match the e820 reserved ranges when walking through the iomem resources
>> with the descriptor 'IORES_DESC_NONE', because several e820 types(
>> e.g. E820_TYPE_RESERVED_KERN/E820_TYPE_RAM/E820_TYPE_UNUSABLE/E820
>> _TYPE_RESERVED) are converted to the descriptor 'IORES_DESC_NONE'. It
>> may pass these four types to the kdump kernel, that is not desired result.
>>
>> So, this patch adds a new I/O resource descriptor 'IORES_DESC_RESERVED'
>> for the iomem resources search interfaces. It is helpful to exactly
>> match the reserved resource ranges when walking through iomem resources.
>>
>> In addition, since the new descriptor 'IORES_DESC_RESERVED' is introduced,
>> these code originally related to the descriptor 'IORES_DESC_NONE' need to
>> be updated. Otherwise, it will be easily confused and also cause some
>> errors. Because the 'E820_TYPE_RESERVED' type is converted to the new
>> descriptor 'IORES_DESC_RESERVED' instead of 'IORES_DESC_NONE', it has been
>> changed.
>>
>> Suggested-by: Dave Young <dyoung@redhat.com>
> 
> This was suggested by Boris instead :) 
> 

Sorry for this, i forgot to change it.
And i will correct this in next version.

Thanks.

>> Signed-off-by: Lianbo Jiang <lijiang@redhat.com>
>> ---
>>  arch/ia64/kernel/efi.c |  4 ++++
>>  arch/x86/kernel/e820.c |  2 +-
>>  arch/x86/mm/ioremap.c  | 13 ++++++++++++-
>>  include/linux/ioport.h |  1 +
>>  kernel/resource.c      |  6 +++---
>>  5 files changed, 21 insertions(+), 5 deletions(-)
>>
>>
> [snip]
> 
> Thanks
> Dave
> 
