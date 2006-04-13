From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 13 Apr 2006 22:43:29 +0000
Subject: RE: Make show_mem() skip holes in a pgdat (V3).
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0637DA9A@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060413182938.GB25701@lnx-holt.americas.sgi.com>
In-Reply-To: <20060413182938.GB25701@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Without this patch on a 512 node 512 cpu system where every node has four
> memory holes, the show_mem() call takes 1 hour 18 minutes.  With this
> patch, it takes less than 3 seconds.

So this is _just_ 1560 times faster.  Not too bad at all (perhaps you
can do this to some other parts of the code :-)

+			end_address += PGD_SIZE;

Umm, Ken said PGDIR_SIZE ... which compiles a lot better.

I did the s/PGD_SIZE/PGDIR_SIZE/ and applied.

-Tony
