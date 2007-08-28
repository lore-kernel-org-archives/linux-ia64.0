From: Brent Casavant <bcasavan@sgi.com>
Date: Tue, 28 Aug 2007 20:56:28 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <20070828151737.P5403@pkunk.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822045714.GD26374@wotan.suse.de>
	<alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
	<200708221202.12403.jesse.barnes@intel.com>
	<20070823022043.GB18788@wotan.suse.de>
	<alpine.LFD.0.999.0708221953360.30176@woody.linux-foundation.org>
	<20070823042038.GI18788@wotan.suse.de>
	<alpine.LFD.0.999.0708230915000.30176@woody.linux-foundation.org>
	<1187886462.5972.17.camel@localhost.localdomain>
	<20070824030904.GC6989@wotan.suse.de>
In-Reply-To: <20070824030904.GC6989@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <npiggin@suse.de>
Cc: linuxppc-dev@ozlabs.org, linux-ia64@vger.kernel.org

On Fri, 24 Aug 2007, Nick Piggin wrote:

> And all platforms other than sn2 don't appear to reorder IOs after
> they leave the CPU, so only sn2 needs to do the mmiowb thing before
> spin_unlock.

I'm sure all of the following is already known to most readers, but
I thought the paragraph above might potentially cause confusion as
to the nature of the problem mmiowb() is solving on SN2.  So for
the record...

SN2 does not reorder IOs issued from a single CPU (that would be
insane).  Neither does it reorder IOs once they've reached the IO
fabric (equally insane).  From an individual CPU's perspective, all
IOs that it issues to a device will arrive at that device in program
order.

(In this entire message, all IOs are assumed to be memory-mapped.)

The problem mmiowb() helps solve on SN2 is the ordering of IOs issued
from multiple CPUs to a single device.  That ordering is undefined, as
IO transactions are not ordered across CPUs.  That is, if CPU A issues
an IO at time T, and CPU B at time T+1, CPU B's IO may arrive at the
IO fabric before CPU A's IO, particularly if CPU B happens to be closer
than CPU B to the target IO bridge on the NUMA network.

The simplistic method to solve this is a lock around the section
issuing IOs, thereby ensuring serialization of access to the IO
device.  However, as SN2 does not enforce an ordering between normal
memory transactions and memory-mapped IO transactions, you cannot
be sure that an IO transaction will arrive at the IO fabric "on the
correct side" of the unlock memory transaction using this scheme.

Enter mmiowb().

mmiowb() causes SN2 to drain the pending IOs from the current CPU's
node.  Once the IOs are drained the CPU can safely unlock a normal
memory based lock without fear of the unlock's memory write passing
any outstanding IOs from that CPU.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
