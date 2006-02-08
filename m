From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Feb 2006 00:05:50 +0000
Subject: RE: ia64 printk_clock()
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05A6D689@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Me too! me too! ;-)
>
> I've never really thought of this feature as being important, but it
> might be good for debugging so getting the extra resolution where
> possible is probably a good thing<tm>.
> 
> What about this, it uses a function pointer that can be updated by the
> machine specific code so architectures which have an alternative
> reliable clock source can use that instead of falling back to the
> jiffies based implementation?

That looks pretty good.  It's a little interesting watching the
boot with CONFIG_PRINTK_TIME=y ... at first lines are printed with
a 0.000000 timestamp because we are using ia64_default_printk_clock()
and jiffies aren't moving yet.  Then I think we switch over to the itc
version, but we still see 0.00000 because the per-cpu nsec_per_cyc
hasn't been initialized yet (multiply by 0 and you get 0).

Once we've read the PAL to get the frequency, we start seeing good
timestamps: until we start bringing up other cpus, when we see a
couple more 0.000000 stamps per cpu.  Not sure if these are because
we printk() before the new cpu has had a chance to set ar.k3, or if
the printk() is before nsec_per_cpu is initialized.

Once all the cpus are up, timestamps proceed in an orderly monotonic
fashion.

-Tony
