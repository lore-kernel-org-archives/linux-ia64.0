From: Jes Sorensen <jes@sgi.com>
Date: Wed, 08 Feb 2006 06:29:19 +0000
Subject: Re: ia64 printk_clock()
Message-Id: <43E98FBF.9030300@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
> That looks pretty good.  It's a little interesting watching the
> boot with CONFIG_PRINTK_TIME=y ... at first lines are printed with
> a 0.000000 timestamp because we are using ia64_default_printk_clock()
> and jiffies aren't moving yet.  Then I think we switch over to the itc
> version, but we still see 0.00000 because the per-cpu nsec_per_cyc
> hasn't been initialized yet (multiply by 0 and you get 0).
> 
> Once we've read the PAL to get the frequency, we start seeing good
> timestamps: until we start bringing up other cpus, when we see a
> couple more 0.000000 stamps per cpu.  Not sure if these are because
> we printk() before the new cpu has had a chance to set ar.k3, or if
> the printk() is before nsec_per_cpu is initialized.

Hi Tony,

Hadn't seen this effect since the SN2 use the global clock source which
is in sync for all CPUs. Would it make sense to use the HPET on systems
that got it?

Cheers,
Jes
