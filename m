From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 17 Mar 2005 23:23:47 +0000
Subject: RE: Recent fix for pgd_addr_end
Message-Id: <16954.4483.890224.229221@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
In-Reply-To: <16953.65276.292620.811032@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Peter" = Peter Chubb <peterc@gelato.unsw.edu.au> writes:

(The reason I'm asking all this is that I still see lots of

/home/peterc/kernels/linux-2.5-import/mm/memory.c:105: bad pmd
20000000000acdc8.
/home/peterc/kernels/linux-2.5-import/mm/memory.c:105: bad pmd
ffff004f00000002.
/home/peterc/kernels/linux-2.5-import/mm/memory.c:105: bad pmd
20000000000acdd0.

messages after booting, even with that change).

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
