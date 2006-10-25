From: Russ Anderson <rja@sgi.com>
Date: Wed, 25 Oct 2006 00:56:45 +0000
Subject: Re: [patch] Mixed Madison and Montecito system support
Message-Id: <200610250056.k9P0ujPY21429663@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20061023205643.GA13990@intel.com> from "Luck, Tony" at Oct 23, 2006 01:56:43 PM
References: <200610130325.k9D3PwIo17962445@clink.americas.sgi.com>
In-Reply-To: <200610130325.k9D3PwIo17962445@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Russ Anderson <rja@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Tony Luck wrote:
> 
> Cc: linux-kernel for generic bit of this change.  Rest of patch was
> posted to linux-ia64: http://marc.theaimsgroup.com/?l=linux-ia64&m6070997529216&w=2
> 
> On Thu, Oct 12, 2006 at 10:25:58PM -0500, Russ Anderson wrote:
> >  int sched_create_sysfs_power_savings_entries(struct sysdev_class *cls)
> >  {
> > -	int err = 0;
> > +	int err = 0, c;
> >  
> >  #ifdef CONFIG_SCHED_SMT
> > -	if (smt_capable())
> > -		err = sysfs_create_file(&cls->kset.kobj,
> > +	for_each_online_cpu(c)
> > +		if (smt_capable(c)) {
> > +			err = sysfs_create_file(&cls->kset.kobj,
> >  					&attr_sched_smt_power_savings.attr);
> > +			break;
> > +		}
> >  #endif
> 
> What if you booted an all-Madison system, and then hot-plugged some
> Montecitos later?  Either we'd need the hotplug cpu code to run through
> this routine again to re-test whether any cpu has multi-thread support
> (it doesn't look like it does that now).
> 
> Or perhaps it would be simpler to dispense with this test and always
> call sysfs_create_file() here (still inside CONFIG_SCHED_SMT) so that
> the hook is always present to tune the scheduler (even if it may be
> ineffective on a no-smt system)?

I like that idea.  Any objections or comments?


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
