From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 31 May 2005 17:55:49 +0000
Subject: RE: [patch 0/4] ia64 SPARSEMEM
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0395C087@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>After reading e-mails,
>	physical address size -- 50bits
>	section size	      -- 32bits
>will be good as a default.
>This can work on any ia64 platforms && Full-sized Hugetlb can 
>be used without any tuning.

But we'll need to update the physical address size every 18 months or
so to add another bit as memory density increases.

CONFIG_VIRTUAL_MEM_MAP will automatically adjust to each system, and won't
need tweaking periodically.

The issue here appears to be that 32-bit systems don't have any spare
virtual address space to devote to a sparse virtual mem_map[] array, so
they need to have the indirection ... but the degree of sparseness tends
to be limited as they support fewer physical address bits.

What are the other benefits of SPARSEMEM that I'm missing?

-Tony
