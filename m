From: Jack Steiner <steiner@sgi.com>
Date: Tue, 18 May 2004 21:01:32 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <20040518210132.GA10484@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 18, 2004 at 01:16:30PM -0700, Ashok Raj wrote:
> On Tue, May 18, 2004 at 09:58:38AM -0500, Russ Anderson wrote:
> > Matthias Fouquet-Lapar wrote:
> > > 
> > > [ Just as a site-note, I always wondered if hotplug would be a useful feature
> > >   for larger configurations to reduce boot-time. For example, on a 64P system 
> > >   you start the kernel on some "root" CPU with a relativly small amount of
> > >   memory, so it should boot relativly fast. While the system is going into
> > >   the desired run-level, hotplug/add now adds in parallel all available CPUs,
> > >   main memory, I/O etc. The idea is that you probably don't need 64P and
> > >   1 Terabyte to start system services
> > > ]
> > 
> > I can certainly think of cases (customers) where minimizing the total
> > system down time is a huge issue.  Getting a subset of the system
> > back into production as quickly as possible would be very desirable.
> > 
> > Another advantage of that type boot process is that it would catch
> > any bugs (or regressions) in the hot add code.  At a minumum, it 
> > would be a very good test of the hot add functionality.
> > 
> > I think a boot option to allow that type of booting process
> > would be a good idea.
> 
> The boot already follows the same methodology, the boot cpu comes up, and the rest of the cpu's are brought up. for e.g. smp_init() does call cpu_up() which is the same path for hotplug.
> 
> Not sure if cpu_up is a time consuming process, i think if you have more cpu's
> the startup could be faster as you have now more resources to complete the 
> statup of kernel.
> 
> Often what i have seen is that the IO part of the probe is the most time
> consuming process. Splitting the discovery of controllers and boot resources
> first, and then deferring the rest if the io discovery process would 
> speedup boot. Also its your firmware that would do the same work as OS 
> in identifying all the controllers and disks upfront that contributes to 
> slow boot.
> 
> bringup all cpu() and then defer part of the probe/discovery (especially
> disks) in parallel would provide real benefit i think.

I agree. 

On the large SGI systems, starting all cpus is fairly fast. The time
consuming parts of boot are:
	- probing disks (depends, of course, on the number)
	- VM init (mem_init, free_bootmem_core)
	- initializing memory structures (arch_memmap_init)

By far, probing is the slowest part of boot on systems with a lot of
disks.



> 
> Cheers,
> ashok
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


