From: Dave Hansen <haveblue@us.ibm.com>
Date: Mon, 17 May 2004 23:28:56 +0000
Subject: RE: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <1084836535.23542.831.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2004-05-17 at 16:18, Luck, Tony wrote:
> >I'd look at SGI's IA64 code for examples of how to create NUMA nodes
> >with only I/O on them.
> 
> The 'M' in NUMA stands for 'Memory' ... so the pedant in me says
> that these I/O only nodes aren't NUMA nodes, perhaps NUIOA?

And the 'A' is Access (or architecture I guess).  Those I/O nodes'
access to memory is non-uniform :)

> Is anyone doing anything to optimize access to such beasts?  Binding
> processes that are accessing such I/O devices to nearby nodes ...
> sounds possible for NIC, and ugly for disks.

Well, binding isn't the best thing to do, but simple preference and
error recovery would be great.  The NUMAQ (and I'm sure others) used to
have a few fiber channel cards in each node that allowed multiple paths
to I/O devices.  You could be fast, and recover from errors since
everything was multiply connected.  We do this on some drivers today,
but not everything.  

-- Dave

