From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 07 May 2003 23:24:09 +0000
Subject: RE: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705659@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Keeping the load address the same would definitely make life easier.
> Otherwise, any tool that depends on System.map may break.
> 
> To be honest, conceptually, I prefer boot-time relocation, because it
> keeps the kernel model simpler (and there is already relocation code
> in the in-kernel module loader which you could leverage).  But having
> the kernel text addresses vary from one machine to another, depending
> on memory configuration is not a exactly a pleasant thought.  I don't
> really have much of a stake in this, so I'd like the folks who really
> care to work out a patch that works on all ia64 NUMA platforms and
> then convince me why it's a good idea to include that patch and why
> it's really The Right Thing.

In case anyone missed the point of this, the issue is handling machines
that don't have physical memory at the location that Linux expects to
be loaded at (some ccNUMA machines that configure memory based on node
numbers cannot guarantee until boot time where any of the memory is physically
located ... depending on which nodes exist).

Here are the approaches that have been proposed and/or tried so far:

1) My patch (posted around October last year) which picked virtual addresses
in the wild blue yonder (initial versions used 0xe002000000000000, later ones
used 0xffffffff00000000) for the link address for the kernel. Elilo can load
kernel at any suitably aligned physical address, and head.S establishes the
mappings using itr[0] and dtr[0].

 pros) provided separate maps for kernel text and data, so supported kernel text
       replication too.
 cons) __pa() no longer works on kernel addresses, use new __tpa() instead.
       Some ugly runtime patching of kernel code to get physical address of
       swapper_pg_dir into the TLB miss code.


2) I think SGI are currently running a modified version of #1 without the text
replication support, and that provides a mapping from the normal virtual
address that the kernel is linked for (0xe00000000044000000) to whatever physical
address it was actually loaded at ... at least I think that's what Jack said.

 pros) simpler than my patch

 cons) Still needs __tpa() instead of __pa() for kernel addresses.

3) David's suggestion of boot-time relocation.  Probably simplest to implement
this in elilo, but if you are really good at PIC asm code it could be done in
the kernel startup sequence.

 pros) Just like linking kernel at a new address.
       Avoids the __tpa() issue.
       Doesn't invalidate any assumptions about how to get from virtual to
       physical addresses and back again.

 cons) Nobody has implemented it.

-Tony

