From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Sat, 04 Oct 2008 00:21:36 +0000
Subject: RE: [PATCH 1/2]Add Variable Page Size and IA64 Support in Intel
Message-Id: <A6AD88C3F2289247BE726C37303E1EB8844A637F@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAE9DCEF64577A439B3A37F36F9B691C0339372B@orsmsx418.amr.corp.intel.com>
 <200810020931.48952.bjorn.helgaas@hp.com>
 <A6AD88C3F2289247BE726C37303E1EB88408ADFF@orsmsx505.amr.corp.intel.com>
 <200810030933.10627.bjorn.helgaas@hp.com>
In-Reply-To: <200810030933.10627.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

>> >> The current Intel IOMMU code assumes that both host page size and Intel IOMMU page size are 4K. The first patch supports variable page size. This provides support for IA64 which has multiple page sizes.
>> >>
> >> This patch also adds some other code hooks for IA64 platform including DMAR_OPERATION_TIMEOUT definition, .
>>
>> >Can you split this patch up?  It contains several logically separate
>> changes:
>> >  - casting things to unsigned long long
>> >  - adding stuff under #ifdef CONFIG_IA64
>> >  - page size changes
>> >  - whitespace changes
>>
>> Depends on who is picking up the generic patch. If it's needed, I can >split it into multiple patches.

>Regardless of who's picking up the patch, splitting it makes it
>easier to review and easier to spot bugs, and makes bisection yield
>better information.

Since more than 95% of code in the patch is directly related to page size changes, splitting the patch will generate one big patch (95% of current patch size) and a few small patches. I would like to still send one single updated patch based on collected comments.

Thanks.

-Fenghua
