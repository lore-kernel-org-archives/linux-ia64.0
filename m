From: Frank Scheiner <frank.scheiner@web.de>
Date: Tue, 25 Jun 2019 09:30:59 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <60d38f5f-4867-ee1d-783c-ae162e25bea9@web.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 6/25/19 10:38, Frank Scheiner wrote:
> On 6/25/19 10:18, Christoph Hellwig wrote:
>> On Tue, Jun 25, 2019 at 10:16:22AM +0200, Frank Scheiner wrote:
>>> Looks like this patch is not enough or not related, a kernel v5.1.15
>>> with that patch applied yields the following:
>>
>> Can you use gdb to disassemle the faulting addresss?
>>
>> Something like:
>>
>> gdb vmlinux
>>
>> The in gdb:
>>
>> l *(__alloc_pages_nodemask+0x281)
>
> Will do. I didn't have gdb installed so it might take some time to
> emerge it. Will report back with the requested information then.

Here's what I get:

```
# gdb ./vmlinux
GNU gdb (Gentoo 8.1 p1) 8.1
[...]
Reading symbols from ./vmlinux...done.
[...]
(gdb) l *(__alloc_pages_nodemask+0x281)
0xa00000010017b901 is in __alloc_pages_nodemask
(./include/linux/mmzone.h:993).
988	 */
989	static __always_inline struct zoneref *next_zones_zonelist(struct
zoneref *z,
990						enum zone_type highest_zoneidx,
991						nodemask_t *nodes)
992	{
993		if (likely(!nodes && zonelist_zone_idx(z) <= highest_zoneidx))
994			return z;
995		return __next_zones_zonelist(z, highest_zoneidx, nodes);
996	}
997
```

Sorry, it took longer than expected, as I was compiling in a ramdisk and
I once again forgot to save that state **before** the reboot with the
v5.1.15 kernel. So I had to recompile the kernel, too (the faulting
address stays the same with the newly compiled kernel!). :-/ But maybe
that was needed anyhow, as my original `.config` had `CONFIG_DEBUG_INFO`
unset.

Cheers,
Frank
