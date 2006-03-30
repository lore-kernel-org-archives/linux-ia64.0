From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 30 Mar 2006 18:28:07 +0000
Subject: RE: show_mem() for ia64 discontig takes a really long time on large systems.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F061AA80C@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
In-Reply-To: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Since we only deal with blocks of memory in IA64_GRANULE_SIZE
pieces (16M or 64M) that would seem to be the natural skip
amount.

Oh, but that is probably still too slow. Jack said he has 180GB
holes ... 180GB/16M = 11520 useless probes and TLB misses.  We'd
be better of to brute force seach the efi_memmap for the next
address when we get a miss.

-Tony
