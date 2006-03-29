From: Jack Steiner <steiner@sgi.com>
Date: Wed, 29 Mar 2006 22:04:16 +0000
Subject: Re: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <20060329220415.GB18889@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 29, 2006 at 12:58:40PM -0800, Luck, Tony wrote:
> > Tiger still boots with my release tree (just has seven patches that
> > haven't been sent to Linus yet, including Russ' fix for my merge
> > goof that created item "3" above).  I haven't pulled in from Linus
> >in about three days, so I'm about 458 commits behind the bleeding
> > edge.  So a "git bisect" between Linus head and the point where I last
> > merged (commit 64bc0430) might yield the problem (for Ken's tiger
> > boot issue).
> 
> Just started the bisection ... and the current tip of Linus' git
> tree (f3cab8a0) booted just fine on tiger!  There are 85 commits
> in there since git-17 was cut, but a quick glance at gitk doesn't
> show any obvious fixes or reverts that might affect ia64.
> 

I don't know if this helps or not.

I ran Jes's kernel on the simulator. Unfortunately, he sent me a stripped
kernel so I have no symbol table.

The kernel blows up right after printing:

	...
	Virtual mem_map starts at 0xa0007fffd5f2c000
	Built 1 zonelists
	Kernel command line: root=/dev/hda2 init=/bin/bash console=ttyS0
	PID hash table entries: 1024 (order: 10, 32768 bytes)
	Console: colour dummy device 80x25

The failure is an MCA caused by a cache hit on a memory reference to an
uncached address. The simulator detects this error & stops.

The code that took the failure was memcopy (or equiv). I recognized the
code from the prefetchs and ld/st sequence. The data appears to be
an ACPI table that is being copied into kernel memory. The current
reference is using uncached addresses but 15M instructions in the past, the
table was referenced cached.

Does this ring any bells with anyone?  This failure may 
occur only in our simulator environment, so don't spent any
time on this unless it sounds familar.

As soon as I get a symbol table, I'll know a lot more about the
failure.

---
Jack
