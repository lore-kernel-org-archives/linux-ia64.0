From: Christoph Lameter <cl@linux.com>
Date: Fri, 07 Jan 2011 16:31:19 +0000
Subject: Re: Very large memory configurations:   > 16 TB
Message-Id: <alpine.DEB.2.00.1101071027040.3014@router.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110106170942.GA8253@sgi.com> <20110107125135.GD20761@elte.hu>
In-Reply-To: <20110107125135.GD20761@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jack Steiner <steiner@sgi.com>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-ia64@vger.kernel.org

Andi put a description of the memory layout in
Documentation/x86/x86_64/mm.txt. Seems to indicate that 64 TB was
considered as a maximum when the memory layout for x86_64 was set up:

------

Virtual memory map with 4 level page tables:

0000000000000000 - 00007fffffffffff (G bits) user space, different per mm
hole caused by [48:63] sign extension
ffff800000000000 - ffff80ffffffffff (@ bits) guard hole
ffff880000000000 - ffffc7ffffffffff (d TB) direct mapping of all phys. memory
ffffc80000000000 - ffffc8ffffffffff (@ bits) hole
ffffc90000000000 - ffffe8ffffffffff (E bits) vmalloc/ioremap space
ffffe90000000000 - ffffe9ffffffffff (@ bits) hole
ffffea0000000000 - ffffeaffffffffff (@ bits) virtual memory map (1TB)
... unused hole ...
ffffffff80000000 - ffffffffa0000000 (Q2 MB)  kernel text mapping, from phys 0
ffffffffa0000000 - fffffffffff00000 (36 MB) module mapping space

The direct mapping covers all memory in the system up to the highest
memory address (this means in some cases it can also include PCI memory
holes).

vmalloc space is lazily synchronized into the different PML4 pages of
the processes using the page fault handler, with init_level4_pgt as
reference.

Current X86-64 implementations only support 40 bits of address space,
but we support up to 46 bits. This expands into MBZ space in the page
tables.

-Andi Kleen, Jul 2004


