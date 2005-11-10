From: Gerald Pfeifer <gp@suse.de>
Date: Thu, 10 Nov 2005 00:03:44 +0000
Subject: RE: [RFC] 4-level page table directories.
Message-Id: <Pine.LNX.4.63.0511100051510.11938@lifschitz.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 9 Nov 2005, Luck, Tony wrote:
> But don't you already have that issue with persuading them to ship with 
> CONFIG_NR_CPUS384?  Surely there are a whole boatload of tuneables 
> and patches needed to get this sized system up and running? 4-level 
> pagetables are just one piece of the puzzle.

Is it possible you are mixing up MAX_NUMALINK_NODES (the maximum
system size, i.e., the maximum number of nodes in a numalink domain)
with CONFIG_NR_CPUS (the maximum SSI size)?

I'm pretty confident SGI has not proposed setting CONFIG_NR_CPUS384
to any OSV. ;-)

Gerald

