From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Mon, 17 May 2004 19:15:50 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <200405171915.i4HJFpOH002584@mtv-vpn-hw-mfl-1.corp.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Don't always equate HOTPLUG with physical removal/addition.
> 
> In the above case of balancing between partitions, its a still a hotplug
> wrt the kernel, where the cpu is removed from os image (say scheduler etc)
> and reintroduce the new resource to another running partition.

Thanks, this make sense. I was previously working on systems which allowed
real physical hot swap, i.e. physical replacement of CPU, memory etc without
OS reboot, hence my questions.

[ Just as a site-note, I always wondered if hotplug would be a useful feature
  for larger configurations to reduce boot-time. For example, on a 64P system 
  you start the kernel on some "root" CPU with a relativly small amount of
  memory, so it should boot relativly fast. While the system is going into
  the desired run-level, hotplug/add now adds in parallel all available CPUs,
  main memory, I/O etc. The idea is that you probably don't need 64P and
  1 Terabyte to start system services
]


Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

