From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Wed, 19 May 2004 09:30:39 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <200405190930.i4J9UfuV001865@mtv-vpn-hw-mfl-1.corp.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Also, I suspect that certain critical system resources (kernel arrays)
> are sized according to how many cpus or how much memory or such is
> available.
> 
> Such placement and sizing can adapt to a few cpus and nodes coming and
> going later on in the life of that system boot, but having what looks
> like a one-lung system turn into a 512 cpu monster sometime after init
> has gone multi-user could result in considerable misconfiguraiton.

I also wondered about this. But doesn't a true hotplug implementation
used for partitions (or cell) reconfiguration require this flexibility
for "on-the-fly scaling" ?

Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

