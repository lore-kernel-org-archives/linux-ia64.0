From: Christopher Wedgwood <cw@sgi.com>
Date: Tue, 29 Jul 2003 18:34:07 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105950380701651@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 24, 2003 at 06:15:42PM -0700, David Mosberger wrote:

> I really would like to see the code that's using
> efi_memmap_walk_uc() first.

I think Jack sent this to you already, but for the benefit of the
list (relevant functions rather than send to the list the entire
driver):

/*
 * fetchop_build_memmap,
 *
 * Called at boot time to build a map of pages that can be used for
 * fetchops.
 */
static int __init
fetchop_build_memmap(unsigned long start, unsigned long end, void *arg)
{
	struct node_fetchops *fops;
	long count, bytes;

	count = (end - start) >> PAGE_SHIFT;
	bytes = sizeof(struct node_fetchops) + count/8;
	fops = vmalloc(bytes);
	memset(fops, 0, bytes);
	fops->maddr = FETCHOP_KADDR_TO_MSPEC_ADDR(start);
	fops->count = count;
	atomic_add(count, &fops->free);
	fetchop_stats.pages_total += count;
	node_fetchops[MSPEC_TO_NID(start)] = fops;

	sn_flush_all_caches((long)__va(start), end - start);

	return 0;
}

/*
 * fetchop_init
 *
 * Called at boot time to initialize the fetchop facility.
 */
int __init
fetchop_init(void)
{
	[...]
	efi_memmap_walk_uc(fetchop_build_memmap, 0);
	printk(KERN_INFO "%s: v%s\n", DRIVER_ID_STR, REVISION);

	return 0;
}


> Also, a check like this:
>
>   Chris> if (md->attribute = EFI_MEMORY_UC)
>
> is almost certainly wrong (md->attribute is a bitmap).

I think the logic here seems to have been uncached ONLY (ie. all other
bits zero).  I guess this falls down if new attributes are added so
something like:

      if ((md->attribute & SOME_MASK) = EFI_MEMORY_UC)
	 [...]

would then be required.  Since this is the only consumer of this
interface thus far I'm not sure it's obvious how the function should
best work.



The issue right now seems to be whether or not this or some variation
of this is useful and/or desirable in the mainline kernel or whether
for now it's best to hide this in the driver until a later stage when
the EFI interfaces are abstracted out a little more to make this
easier?



Thanks,
  --cw
