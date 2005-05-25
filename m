From: Bob Picco <bob.picco@hp.com>
Date: Wed, 25 May 2005 15:13:47 +0000
Subject: [patch 0/4] V2 ia64 SPARSEMEM
Message-Id: <20050525151347.GB23448@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

ChangeLog V2:
	Jesse's review input has been applied to patches 3 and 4.
	These were all cosmetic changes.

This is a series of patches which enable SPARSEMEM for ia64.  It's against
rc4-mm2.  The patches have been tested against memory configurations FLATMEM,
DISCONTIG and SPARSEMEM.  This includes NUMA simulated hardware, rx2600
and HPSIM.  An early version of ia64 with SPARSEMEM was tested by Jesse. It
would be optimal to have another test pass on SGI NUMA hardware.

Ultimately I would like to eliminate DISCONTIG and VIRTUAL_MEM_MAP. Before 
this can be accomplished, more performance comparisons between SPARSEMEM 
and DISCONTIG+VIRTUAL_MEM_MAP is required.  I did some preliminary performance
work with 2 CPU rx2600.  The results were comparable and no noticeable 
regression was evidenced.  Further work on multi node NUMA machines is
required.

thanks,

bob

