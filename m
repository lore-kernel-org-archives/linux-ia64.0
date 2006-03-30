From: Jes Sorensen <jes@sgi.com>
Date: Thu, 30 Mar 2006 09:04:25 +0000
Subject: Re: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <yq0u09guwva.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jack" = Jack Steiner <steiner@sgi.com> writes:

Jack> 	...  Virtual mem_map starts at 0xa0007fffd5f2c000 Built 1
Jack> zonelists Kernel command line: root=/dev/hda2 init=/bin/bash
Jack> console=ttyS0 PID hash table entries: 1024 (order: 10, 32768
Jack> bytes) Console: colour dummy device 80x25

Jack> The failure is an MCA caused by a cache hit on a memory
Jack> reference to an uncached address. The simulator detects this
Jack> error & stops.

Hi Jack,

Sorry about the missing symbol table, was a bit late.

I am not sure it's the same thing, as my kernel gets a lot further and
normally spawns init before exploding.

Jack> The code that took the failure was memcopy (or equiv). I
Jack> recognized the code from the prefetchs and ld/st sequence. The
Jack> data appears to be an ACPI table that is being copied into
Jack> kernel memory. The current reference is using uncached addresses
Jack> but 15M instructions in the past, the table was referenced
Jack> cached.

Jack> Does this ring any bells with anyone?  This failure may occur
Jack> only in our simulator environment, so don't spent any time on
Jack> this unless it sounds familar.

Jack> As soon as I get a symbol table, I'll know a lot more about the
Jack> failure.

I put one up on attica for you ~jes/System.map-jack

It seems the kernel explodes in __copy_user in your case.

Cheers,
Jes
