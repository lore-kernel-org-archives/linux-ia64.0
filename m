From: Andi Kleen <ak@suse.de>
Date: Thu, 04 Nov 2004 04:07:13 +0000
Subject: Re: Externalize SLIT table
Message-Id: <20041104040713.GC21211@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041103205655.GA5084@sgi.com> <20041104.105908.18574694.t-kochi@bq.jp.nec.com>
In-Reply-To: <20041104.105908.18574694.t-kochi@bq.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
Cc: steiner@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Nov 04, 2004 at 10:59:08AM +0900, Takayoshi Kochi wrote:
> Hi,
> 
> For wider audience, added LKML.
> 
> From: Jack Steiner <steiner@sgi.com>
> Subject: Externalize SLIT table
> Date: Wed, 3 Nov 2004 14:56:56 -0600
> 
> > The SLIT table provides useful information on internode
> > distances. Has anyone considered externalizing this
> > table via /proc or some equivalent mechanism.
> > 
> > For example, something like the following would be useful:
> > 
> > 	# cat /proc/acpi/slit
> > 	010 066 046 066
> > 	066 010 066 046
> > 	046 066 010 020
> > 	066 046 020 010
> > 
> > If this looks ok (or something equivalent), I'll generate a patch....

This isn't very useful without information about proximity domains.
e.g. on x86-64 the proximity domain number is not necessarily 
the same as the node number. 


> For user space to manipulate scheduling domains, pinning processes
> to some cpu groups etc, that kind of information is very useful!
> Without this, users have no notion about how far between two nodes.

Also some reporting of _PXM for PCI devices is needed. I had a 
experimental patch for this on x86-64 (not ACPI based), that
reported nearby nodes for PCI busses. 

> 
> But ACPI SLIT table is too arch specific (ia64 and x86 only) and
> user-visible logical number and ACPI proximity domain number is
> not always identical.

Exactly.

> 
> Why not export node_distance() under sysfs?
> I like (1).
> 
> (1) obey one-value-per-file sysfs principle
> 
> % cat /sys/devices/system/node/node0/distance0
> 10

Surely distance from 0 to 0 is 0?

> % cat /sys/devices/system/node/node0/distance1
> 66

> 
> (2) one distance for each line
> 
> % cat /sys/devices/system/node/node0/distance
> 0:10
> 1:66
> 2:46
> 3:66
> 
> (3) all distances in one line like /proc/<PID>/stat
> 
> % cat /sys/devices/system/node/node0/distance
> 10 66 46 66

I would prefer that. 

-Andi
