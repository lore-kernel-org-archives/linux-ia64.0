From: "Howell, David P" <david.p.howell@intel.com>
Date: Wed, 19 May 2004 14:40:15 +0000
Subject: RE: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <331AD7BED1579543AD146F5A1A44D52504185787@fmsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Seems like to do this right you would need a dependence based init 
script implementation, i.e. do step D when steps A, B, and C have 
successfully completed. This would permit more granular bringup of 
services when the hardware/driver initialization has completed.

Thanks,
Dave Howell

These are my opinions and not official opinions of Intel Corp.
 
David Howell
Intel Corporation
Telco Server Development
Server Products Division
Voice: (803) 216-2359  Fax: (803) 216-2178
 
Intel Corporation
Columbia Design Center, CBA-1
100 Center Point Circle, Suite 210
Columbia, SC 29210
 
david.p.howell@intel.com
 

-----Original Message-----
From: linux-ia64-owner@vger.kernel.org
[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Matthias
Fouquet-Lapar
Sent: Wednesday, May 19, 2004 1:25 AM
To: Raj, Ashok
Cc: Russ Anderson; Matthias Fouquet-Lapar; Raj, Ashok; Dave Hansen;
Yasunori Goto; Paul Jackson; lhns-devel@lists.sourceforge.net; hotplug
devel; colpatch@us.ibm.com; linux-ia64@vger.kernel.org; Greg KH;
tokunaga.keiich@jp.fujitsu.com; pfg@SGI.COM; IWAMOTO Toshihiro
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node
hotplug?

> The boot already follows the same methodology, the boot cpu comes up,
and the rest of the cpu's are brought up. for e.g. smp_init() does call
cpu_up() which is the same path for hotplug.

My point was that if it would make sense to get one CPU with a mininmal
amount of memory through the entire boot sequence, so it can start
system 
daemons etc. Depending on the configuration, this typically takes some
time. 

While this is happening, HW resources can be added on the fly using
hotplug

> Not sure if cpu_up is a time consuming process, i think if you have
more cpu's
> the startup could be faster as you have now more resources to complete
the 
> statup of kernel.

Again my suggestion was to complete the boot of the kernel with a
minimal
set of resources (TBD). To me it's seems like overkill to have all CPUs
and main memory ready before you an start sendmail, printer daemon etc.

Of course, you might want to have I/O ready before mounting disk drives

> bringup all cpu() and then defer part of the probe/discovery
(especially
> disks) in parallel would provide real benefit i think.

I would take it one step farther in that the system already can go for
example to multi-user before all HW resources are attached

Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET
521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1
3047 4127

-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
