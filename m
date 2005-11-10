From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 10 Nov 2005 00:27:48 +0000
Subject: RE: [RFC] 4-level page table directories.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04EADF45@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Is it possible you are mixing up MAX_NUMALINK_NODES (the maximum
>system size, i.e., the maximum number of nodes in a numalink domain)
>with CONFIG_NR_CPUS (the maximum SSI size)?
>
>I'm pretty confident SGI has not proposed setting CONFIG_NR_CPUS384
>to any OSV. ;-)

It's always possible that I'm confused.  Here's the message where
Robin introduced the rationale for 4-level page tables:

 http://tinyurl.com/bewsk

In that he says "current = 2048" ... which I think is how many
cpus can be in the whole box ... 512 is the current max cpus in
a coherence domain (and thus the max that a single instance of
Linux will see today).

With Montecito (dual core, two threads in each core) the number
of cpus Linux sees will be quadrupled in a system with the same
number of sockets.  Add more sockets, and the 16384 number may
not be impossible.

-Tony
