From: Dave Hansen <haveblue@us.ibm.com>
Date: Mon, 17 May 2004 08:23:49 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <1084782228.24128.5291.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2004-05-17 at 00:35, Matthias Fouquet-Lapar wrote:
> > There's been a lot of talk of what to do with hotplug CPUs as well.  No
> > matter what, it's going to be really easy to notify whatever app you
> > want with the hotplug scripts whenever a memory or CPU event happens. 
> > Just place your app script in /etc/hotplug.d.
> 
> Just curious, but what's the underlying reason for providing CPU hotplug ?
> If the background is taking a "bad" CPU offline, what kind of CPU failures
> are expected to be covered ? 

In the ppc64 case, there is some partitioning that can be done of a
large system.  CPU hotplug lets us balance cpu power between
partitions.  You can also buy a machine with 32 cpus, but only have 16
of them turned on. There's a switch you can flip to get more horsepower
only when you need it.  (for a price, of course)

There's a quick mention of failure recovery here:
http://www-1.ibm.com/servers/eserver/pseries/hardware/whitepapers/lpar_3.html

But, the story on ppc64 is pretty much that the firmware detects the
kinds of hardware failures that we handle, Linux is just notified of it
afterword.  

Remember, chips designs like the POWER4 tend to have a lot of cost and
design overhead in error correction and detection that are quite absent
from consumer type cpus.

-- Dave

