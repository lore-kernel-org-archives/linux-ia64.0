From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Wed, 02 Mar 2005 01:20:38 +0000
Subject: Re: take7: vector sharing (Large I/O system support)
Message-Id: <422514E6.80509@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42226CCE.6070706@jp.fujitsu.com>
In-Reply-To: <42226CCE.6070706@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Hellwig wrote:
>>
>>The problem is naming, I think.  Those aren't "cache entries", they
>>are statically preallocated entries.  How about changing the config
>>option name to:
> 
> 
> Even for early allocations what speaks against alloc_bootmem?
> 
> 

I didn't use alloc_bootmem because I thought alloc_bootmem was
very simple allocator and we should not use it to allocate
arbitrary size (not PAGE_SIZE * n) of memory so frequently.
But I don't know about it very much and my understanding might
be incorrect.

Can I use alloc_bootmem as well as kmalloc to allocate arbitrary
size of memory?

Thanks,
Kenji Kaneshige
