From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 22 Sep 2003 23:26:39 +0000
Subject: Re: [PATCH] discontig patch (still ugly)
Message-Id: <marc-linux-ia64-106427342406070@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106426937002232@msgid-missing>
In-Reply-To: <marc-linux-ia64-106426937002232@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


  >> - MAX_RSVD_REGIONS et al got moved to pgtable.h; why in the world would
  >> that be the right place?  Just because "it compiled"??

  Jesse> No, because that was necessary for the contig.c/discontig.c
  Jesse> seperation.  Which header file would be better?

I think it could be just a local header file in arch/ia64/kernel/.

  >> - why is there both vmem_map and mem_map in the NUMA case?

  Jesse> You mean for the discontig case?  mem_map isn't there.  It
  Jesse> only exists (mm/memory.c) if CONFIG_DISCONTIGMEM is off,
  Jesse> otherwise we just use vmem_map and pgdata_t->node_mem_map for
  Jesse> everything.

Then fix mm/memory.c to define mem_map if CONFIG_VIRTUAL_MEMMAP is on.

	--david
