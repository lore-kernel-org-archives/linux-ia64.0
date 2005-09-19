From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 19 Sep 2005 08:35:45 +0000
Subject: Re: Attribute spinlock contention ticks to caller.
Message-Id: <20050919083545.GB9005@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
In-Reply-To: <20050914222644.GA5036@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin,

On Mon, Sep 19, 2005 at 10:52:11AM -0700, David Mosberger-Tang wrote:
> And as Stephane already explained, if you use the right tool, there is
> no need for the hack that you suggest.  You can either use a
> q-syscollect-like approach (which will give you call-counts, but not
> necessarily distribute the time accurately) or you can unwind the
> call-stack and even distribute the time correctly.  That's all doable
> today without any special-case hacks.
> 

If you still have your test case. Could you run q-syscollect
on it and see how close you get from the profile you get with
the modified handler? Look at the kernel profile. Would that
be good enough to track down the problem?


The other issue I have with this patch is that it is non-portable.
The next version of perfmon works on multiple architectures. In
particular the default sampling format  is used by i386, x86-64, ia-64,
ppc64. Your patch would not work with those because it contains
IA-64 specific code yet I think the same problem exists on those
architectures as well.

>   --david
> 
> On 9/19/05, Robin Holt <holt@sgi.com> wrote:
> > On Sun, Sep 18, 2005 at 06:18:20PM -0700, David Mosberger-Tang wrote:
> > > Well, it's an example where attributing the spinlock contention time
> > > to the caller would have completely obfuscated the problem.
> > 
> > Either way, we have obfuscation.  In the one case (attributing to caller),
> > the obfuscation can be resolved by looking at the code.  In the other
> > (multiple paths contending on independent locks), the obfuscation can
> > only be resolved by repeating the test with different sampling.
> > 
> > Although that sounds simple, what if it is a difficult to execute test.
> > What if this appeared to be a one-time aberration that was captured during
> > one of many iterations.  The chance to capture is gone.
> > 
> > For a more complete illustration, I would like to elaborate my previous
> > example.  I had a sample file produced by our benchmarkers.  They had
> > received the results on their third run after tweaking some app settings
> > and the results were nearly impossible to believe.  This happened to be
> > an MPI job where all ranks barrier at the end of a phase so one single
> > rank being slow results in the entire application being slow.
> > 
> > After the third run, they repeated with the app settings from the
> > second run and then repeated again with the settings from the third
> > run.  Neither run showed any signs of a similar problem.  The customer
> > acceptance test continued.  Before the customer would accept the results,
> > they needed that anomaly explained.
> > 
> > Fortunately, the customer had required a sampling output from every
> > run so data had been taken using perfmon and retained.  This was on a
> > 2.4 based system.  The system had eight Ethernet adapters spread across
> > the machine.  Interrupts for each were targeted to different cpus.
> > 
> > Because sampling was showing the caller, this turned into a simple
> > question, why was there so much network receive activity.  On some of
> > the cpus, we noticed a significant number of processes were trying to
> > en-queue network packets at the same time.  The sample IP showed we were
> > in a bundle after a spinlock was acquired.
> > 
> > Had we not provided the caller, we would have been left with something
> > that was relatively impossible to diagnose definitively.  With the unroll,
> > it became a simple matter of looking at the enabled network services and
> > finding somebody had run a network benchmark using all eight network
> > adapters.  We contacted the group responsible for network benchmarks
> > and the problem was isolated and explained to the customers satisfaction.
> > 
> > I hope this illustrates that one way of sampling makes it slightly more
> > difficult to determine that the source of slowdown is contention on
> > a lock where the other way of sampling results in it being impossible
> > to determine the source of a problem.  Given the choices, I would say
> > the right way to do the sampling is to not attribute the samples to
> > the caller.
> > 
> > Thanks,
> > Robin
> > 
> 
> 
> -- 
> Mosberger Consulting LLC, voice/fax: 510-744-9372,
> http://www.mosberger-consulting.com/
> 35706 Runckel Lane, Fremont, CA 94536
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 

-Stephane
