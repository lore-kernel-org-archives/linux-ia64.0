From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Wed, 19 May 2004 14:56:50 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <200405191456.i4JEup7T002310@mtv-vpn-hw-mfl-1.corp.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Seems like to do this right you would need a dependence based init 
> script implementation, i.e. do step D when steps A, B, and C have 
> successfully completed. This would permit more granular bringup of 
> services when the hardware/driver initialization has completed.

Probably something like this, although I'm not sure if it would need
to be hierarchically. Maybe split into device categories, disk, network
etc. The goal to keep in mind is the minimization of customer visible
down-time either due to a system crash (HW/SW), hotplug configuration 
changes, power outage etc

Or let's say you need to take a system dump. Maybe we can dump the
first 128 MB within a few seconds and then start rebooting the minimal
configuration. System dumping continues and while memory is saved for
post-mortem dump analysis, saved memory pages are added hot-plug 
back into operation.  (or maybe on a DIMM level to make life easier)

Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

