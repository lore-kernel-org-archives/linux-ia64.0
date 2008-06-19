From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 19 Jun 2008 17:15:09 +0000
Subject: RE: [PATCH 09/27] ia64/xen: implement the arch specific part of
Message-Id: <57C9024A16AD2D4C97DC78E552063EA306213BE8@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12130840434082-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12130840434082-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> +#define is_kernel_addr(x)                                      \
>> +       ((PAGE_OFFSET <= (x) &&                                 \
>> +         (x) < (PAGE_OFFSET + (1UL << IA64_MAX_PHYS_BITS))) || \
>> +        (KERNEL_START <= (x) &&                                \
>> +         (x) < KERNEL_START + KERNEL_TR_PAGE_SIZE))
>>
>> Misleading name.  What does it consider a "kernel_addr"? Just
>> region 7 (up to physical address limit) and the piece of region
>> 5 that is mapped by itr[0]/dtr[0].  Preferebly pick a better name
>> or add a comment here saying what this is testing for.
>
> How about xencomm_is_phys_contiguous()?
> Renaming it requires patches to drivers/xen/xencomm.c.
> If okay, I'll also send the patch to common files.

That sounds a bit more meaningful ... except that such a function
would also require a "size" (or "end") parameter. It makes
no sense to ask whether a solitary address is contiguous.

-Tony
