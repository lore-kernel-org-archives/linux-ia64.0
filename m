From: Paul Jackson <pj@sgi.com>
Date: Wed, 19 May 2004 09:17:58 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <20040519021758.4c4ddb71.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> My point was that if it would make sense to get one CPU with a mininmal
> amount of memory through the entire boot sequence, so it can start system
> daemons ...

The placement and initialization of system daemons on large systems
sometimes depends on the system configuration.  Besides the obvious
set of daemon kernel threads that are established one per cpu or one
per node, there may be an intentional placement of classic Unix daemons
to run on a subset of the available cpus or memory, in order to free
up the rest of the system for dedicated application use.

Also, I suspect that certain critical system resources (kernel arrays)
are sized according to how many cpus or how much memory or such is
available.

Such placement and sizing can adapt to a few cpus and nodes coming and
going later on in the life of that system boot, but having what looks
like a one-lung system turn into a 512 cpu monster sometime after init
has gone multi-user could result in considerable misconfiguraiton.

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
