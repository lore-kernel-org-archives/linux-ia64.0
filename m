From: Ashok Raj <ashok.raj@intel.com>
Date: Tue, 07 Dec 2004 15:54:55 +0000
Subject: Re: CPU hot-remove - Handoff Processor to SAL
Message-Id: <20041207075455.A12277@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041206220159.A7973@unix-os.sc.intel.com>
In-Reply-To: <20041206220159.A7973@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 07, 2004 at 03:04:14PM +0000, Matthew Wilcox wrote:
> On Mon, Dec 06, 2004 at 10:01:59PM -0800, Ashok Raj wrote:
> > @@ -609,8 +643,10 @@ void __cpu_die(unsigned int cpu)
> >  			 * TBD: Enable this when physical removal
> >  			 * or when we put the processor is put in
> >  			 * SAL_BOOT_RENDEZ mode
> > -			 * cpu_clear(cpu, cpu_callin_map);
> > +			 cpu_clear(cpu, cpu_callin_map);
> > +			 printk ("Clearing cpu_callin_map\n");
> >  			 */
> > +			printk ("Now cpu %d is dead\n", cpu);
> >  			return;
> >  		}
> >  		current->state = TASK_UNINTERRUPTIBLE;
> 
> Is this just a debugging printk?  I wouldn't be too happy if a customer
> sees the message "Now cpu 3 is dead" in their logs.  I can almost hear
> the terrified support call now ...

Very funny!! 


I will change it, if there are any updates in the next round.
> 
> "I asked the machine to take the CPU offline and now it's dead!  My boss
> is going to kill me!"
> 

-- 
Cheers,
Ashok Raj
- Open Source Technology Center
  Intel Corporation
