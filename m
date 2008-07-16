From: Alex Chiang <achiang@hp.com>
Date: Wed, 16 Jul 2008 01:11:42 +0000
Subject: Re: [PATCH 01/14] Introduce cpu_enabled_map and friends
Message-Id: <20080716011142.GI10919@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080715023344.2528.1836.stgit@blender.achiang> <20080715023349.2528.9423.stgit@blender.achiang> <20080715031512.GF14894@parisc-linux.org> <87wsjnxy4w.fsf@basil.nowhere.org> <20080715102130.GA22866@flint.arm.linux.org.uk> <20080715175740.GB10919@ldl.fc.hp.com> <20080715181632.GG14894@parisc-linux.org> <20080715184822.GB29991@flint.arm.linux.org.uk>
In-Reply-To: <20080715184822.GB29991@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

* Russell King <rmk+lkml@arm.linux.org.uk>:
> On Tue, Jul 15, 2008 at 12:16:32PM -0600, Matthew Wilcox wrote:
> > On Tue, Jul 15, 2008 at 11:57:40AM -0600, Alex Chiang wrote:
> > > My thought was that big SMP systems like ia64, possibly sparc and
> > > ppc, and increasingly, x86, might find something like this
> > > useful, as systems get larger and larger, and vendors are going
> > > to want to do RAS-ish features, like the ability to keep CPUs in
> > > firmware across reboots until told otherwise by the sysadmin.
> > > 
> > > Right now, a 'present' CPU strongly implies 'online' as well,
> > > since we're calling cpu_up() for all 'present' CPUs in
> > > smp_init(). But this hurts if:
> > > 
> > > 	- you don't actually want to bring up all 'present' CPUs
> > > 	- you still want to interact with these weirdo zombie
> > > 	  CPUs that are 'present' but not 'online'
> > 
> > Have you considered simply failing __cpu_up() for CPUs that are
> > deconfigured by firmware?
> 
> But what if you want to have a system boot with, say, 4 CPUs and
> then decide at run time to bring up another 4 CPUs when required?
> 
> How about having smp_init() call into arch code to query whether
> it should bring up a not-already-online CPU?  Architectures that
> want to do something special can then make the decision there and
> everyone else can define the test completely away.

I experimented today with an ia64-only solution, keeping track of
'present' vs 'enabled' vs 'online' all in arch-specific code.

The arch-specific stuff turns out to be more or less a wash; that
is, it's not too hard to keep it all in ia64.

However, the problem is, I would still need a generic
'enabled_map' to control whether 'online' and 'crash_notes'
entries get created for /sys/devices/system/cpu/cpuN/.

So if other archs are at least neutral on this class of CPUs, I
can work on another patchset that lowers the tax to a simple
#define for archs that don't care.

But if people hate this idea of a new map, I'd like to know so
that I'm not wasting my time and can work on a different solution
(what that would be, I have no idea at the moment).

Thanks.

/ac

