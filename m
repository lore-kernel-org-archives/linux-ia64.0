From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Wed, 19 May 2004 05:25:11 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <200405190525.i4J5PCpv001281@mtv-vpn-hw-mfl-1.corp.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The boot already follows the same methodology, the boot cpu comes up, and the rest of the cpu's are brought up. for e.g. smp_init() does call cpu_up() which is the same path for hotplug.

My point was that if it would make sense to get one CPU with a mininmal
amount of memory through the entire boot sequence, so it can start system 
daemons etc. Depending on the configuration, this typically takes some time. 

While this is happening, HW resources can be added on the fly using hotplug

> Not sure if cpu_up is a time consuming process, i think if you have more cpu's
> the startup could be faster as you have now more resources to complete the 
> statup of kernel.

Again my suggestion was to complete the boot of the kernel with a minimal
set of resources (TBD). To me it's seems like overkill to have all CPUs
and main memory ready before you an start sendmail, printer daemon etc.

Of course, you might want to have I/O ready before mounting disk drives

> bringup all cpu() and then defer part of the probe/discovery (especially
> disks) in parallel would provide real benefit i think.

I would take it one step farther in that the system already can go for
example to multi-user before all HW resources are attached

Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

