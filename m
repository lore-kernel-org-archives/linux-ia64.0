From: lijiang <lijiang@redhat.com>
Date: Tue, 27 Nov 2018 02:58:38 +0000
Subject: Re: [PATCH 0/2 RESEND v7] add reserved e820 ranges to the kdump kernel e820 table
Message-Id: <463c284b-115e-0784-ca07-a430127e6176@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181124051223.19994-1-lijiang@redhat.com>
 <35e8ade5-d5a8-b5e4-180b-44b4ff0a83b1@intel.com>
In-Reply-To: <35e8ade5-d5a8-b5e4-180b-44b4ff0a83b1@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org
Cc: kexec@lists.infradead.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-efi@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, akpm@linux-foundation.org, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, ard.biesheuvel@linaro.org, tony.luck@intel.com, fenghua.yu@intel.com, dyoung@redhat.com, bhe@redhat.com

在 2018年11月27日 02:54, Dave Hansen 写道:
> On 11/23/18 9:12 PM, Lianbo Jiang wrote:
>> These patches add the new I/O resource descriptor 'IORES_DESC_RESERVED'
>> for the iomem resources search interfaces, and in order to make it still
>> work after the new descriptor is added, these codes originally related
>> to 'IORES_DESC_NONE' have been updated.
> 
> This is rather anemic "0/" text.  Could you please include some more
> background in here?  The 2/2 patch is pretty good in this regard, but it
> needs to be here, too.
> 

Thanks for your comment. 

Originally, this patch added the e820 reserved ranges by accurately comparing
a string. It only modifies fewer code paths. Please refer to patch v6.
https://lore.kernel.org/lkml/20181114072926.13312-2-lijiang@redhat.com/

Because the string comparison is fragile and error-prone, this patch used the
solution that adds a new descriptor 'IORES_DESC_RESERVED'. Please refer to this
link: https://lore.kernel.org/lkml/20181120192935.GK2527@zn.tnic/

When passing the e820 reserved ranges to the second kernel, why does it need to
compare strings accurately or add a new descriptor 'IORES_DESC_RESERVED'?

-The reason is that it can not exactly match the e820 reserved resource ranges
when walking through iomem resources with the descriptor 'IORES_DESC_NONE'.

Thanks.
Lianbo
