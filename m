From: Andi Kleen <ak@suse.de>
Date: Tue, 18 May 2004 21:05:01 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <20040518210501.GI2512@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On the large SGI systems, starting all cpus is fairly fast. The time
> consuming parts of boot are:
> 	- probing disks (depends, of course, on the number)
> 	- VM init (mem_init, free_bootmem_core)
> 	- initializing memory structures (arch_memmap_init)
> 
> By far, probing is the slowest part of boot on systems with a lot of
> disks.

We should really have parallel scanning for disks ...
That would help on smaller system too.

-Andi
