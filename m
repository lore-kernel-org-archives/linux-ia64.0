From: Aron Griffis <aron@hp.com>
Date: Tue, 09 Mar 2004 21:13:08 +0000
Subject: Re: crash on SysRq : Show Memory
Message-Id: <20040309211308.GG10141@mustard.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040309160904.GF7569@mustard.americas.cpqcorp.net>
In-Reply-To: <20040309160904.GF7569@mustard.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jesse Barnes wrote:	[Tue Mar 09 2004, 02:25:41PM EST]
> Ah, zx1 then.  I accidentally deleted the original backtrace

http://dev.gentoo.org/~agriffis/oops.txt

> and it
> doesn't appear to be in the list archives yet, but I'm guessing that
> since the panic occured at arch/ia64/mm/contig.c:show_mem+0x100, I'm
> guessing the problem is somewhere after the call to show_free_areas().
> I don't have a zx1 box that's easy to test with, so I probably won't be
> much help.

So I have the vmlinux which was built with debugging symbols (I assume
this is why I got a backtrace as well)...  however I'm not immediately
seeing how to trace this back into show_mem()

$ gdb vmlinux
(gdb) list *(show_mem+0x100)
0xa00000010005b9e0 is in show_mem (bitops.h:280).
275     }
276
277     static __inline__ int
278     test_bit (int nr, const volatile void *addr)
279     {
280             return 1 & (((const volatile __u32 *) addr)[nr >> 5] >> (nr & 31));
281     }
282
283     /**
284      * ffz - find the first zero bit in a long word

--
Aron Griffis
hp Linux and Open Source Lab
Key fingerprint = 4601 AE87 379D A917 BA62  5263 C284 0366 5E6A 3C6B

