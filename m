From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Mon, 17 May 2004 08:38:49 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <200405170838.i4H8coY7001703@mtv-vpn-hw-mfl-1.corp.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> In the ppc64 case, there is some partitioning that can be done of a
> large system.  CPU hotplug lets us balance cpu power between
> partitions.  You can also buy a machine with 32 cpus, but only have 16
> of them turned on. There's a switch you can flip to get more horsepower
> only when you need it.  (for a price, of course)
> 
> There's a quick mention of failure recovery here:
> http://www-1.ibm.com/servers/eserver/pseries/hardware/whitepapers/lpar_3.html
> 
> But, the story on ppc64 is pretty much that the firmware detects the
> kinds of hardware failures that we handle, Linux is just notified of it
> afterword.  

I think I'm not quite sure why you need hotplug to balance CPUs between
partitons. (You are not moving physical components for this, right ?)

> Remember, chips designs like the POWER4 tend to have a lot of cost and
> design overhead in error correction and detection that are quite absent
> from consumer type cpus.

Taken beside which CPU architecture has best the RAS features :-), which are
CPU error types on ppc64 (besides cache SBE etc) which allow gracefully
recovery (i.e. the OS continues operating and non-affected user processes
continue to run) and hotplug replacement 

Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

