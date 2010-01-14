From: Christoph Lameter <cl@linux-foundation.org>
Date: Thu, 14 Jan 2010 15:01:33 +0000
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
Message-Id: <alpine.DEB.2.00.1001140858460.14164@router.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001130851310.24496@router.home> <20100114005304.GC27766@ldl.fc.hp.com>
In-Reply-To: <20100114005304.GC27766@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Chiang <achiang@hp.com>
Cc: penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org

On Wed, 13 Jan 2010, Alex Chiang wrote:

> Firmware puts each cell into a NUMA node, so we should really
> only have 2 nodes, but for some reason, that 3rd node gets
> created too. I haven't inspected the SRAT/SLIT on this machine
> recently, but can do so if you want me to.

May not have anything to do with the problem we are looking at but memory
setup is screwed up. Funky effects may follow.

> > Maybe we miscalculated the number of DMA caches needed.
> > Does this patch fix it?
>
> Nope, same oops.

Duh. Have to look at this in more detail.

> ACPI: SLIT table looks invalid. Not used.
> Number of logical nodes in system = 3
> Number of memory chunks in system = 5

SLIT table just contain the distances if I remember correctly. The memory
maps are separate.

