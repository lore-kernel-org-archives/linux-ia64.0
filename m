From: Alex Chiang <achiang@hp.com>
Date: Mon, 09 Feb 2009 22:50:00 +0000
Subject: Re: RCU can use cpu_active_map?
Message-Id: <20090209225000.GC3939@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090209201345.GB13107@ldl.fc.hp.com> <20090209213929.GQ6802@linux.vnet.ibm.com>
In-Reply-To: <20090209213929.GQ6802@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>

* Paul E. McKenney <paulmck@linux.vnet.ibm.com>:
> On Mon, Feb 09, 2009 at 01:13:45PM -0700, Alex Chiang wrote:
> > Paul,
> > 
> > I don't pretend to understand RCU, but a very quick and naive
> > look through rcupreempt.c makes me think that we could use the
> > cpu_active_map instead of cpu_online_map?
> > 
> > cpu_active_map was introduced by e761b772.
> > 
> > In the CPU hotplug path, we touch the cpu_active_map very early
> > on:
> > 
> > int __ref cpu_down(unsigned int cpu)
> > {
> >         int err;
> >         err = stop_machine_create();
> >         if (err)
> >                 return err;
> >         cpu_maps_update_begin();
> > 
> >         if (cpu_hotplug_disabled) {
> >                 err = -EBUSY;
> >                 goto out;
> >         }
> > 
> >         cpu_clear(cpu, cpu_active_map);
> > 	/* ... */
> >         synchronize_sched();
> >         err = _cpu_down(cpu, 0);
> >         if (cpu_online(cpu))
> >                 cpu_set(cpu, cpu_active_map);
> > 
> > out:
> >         cpu_maps_update_done();
> >         stop_machine_destroy();
> >         return err;
> > }
> > 
> > The call to _cpu_down() is where we eventually get to the code
> > that my patch below touches, so you can see that we mark the CPU
> > as !active before we ever get to the step of migrating interrupts
> > (which relies on cpu_online_map).
> > 
> > If RCU looked at cpu_active_map instead of cpu_online_map, it
> > seems like we would avoid the potential race situation you
> > mentioned earlier.
> > 
> > Alternatively, I could explore just playing with the ia64
> > interrupt migration code to use cpu_active_mask instead, but
> > wanted to get your thoughts from the RCU perspective.
> 
> Perhaps I am confused, but if the CPU is on its way down, doesn't RCU
> need a mask where the CPU's bit stays set longer rather than shorter?
> 
> If I use cpu_active_mask, couldn't there be device interrupts during
> (for example) the synchronize_sched(), which might have RCU read-side
> critical sections that RCU needs to pay attention to?

Hm, I think you're right.

Thanks.

/ac

