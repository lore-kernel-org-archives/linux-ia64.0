From: Robin Holt <holt@sgi.com>
Date: Thu, 06 Nov 2003 20:31:14 +0000
Subject: Re: [DMESG] cpumask_t in action
Message-Id: <marc-linux-ia64-106815119320838@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106807117402763@msgid-missing>
In-Reply-To: <marc-linux-ia64-106807117402763@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 06, 2003 at 10:56:55AM -0800, Luck, Tony wrote:
> > That'd cut us down to:
> > 
> > > CPU 3: 61 virtual and 50 physical address bits
> > > CPU 3: nasid 2, slice 2, cnode 1
> > > CPU 3: base freq 0.000MHz, ITC ratio/2, ITC freq00.000MHz+/--1ppm
> > > Calibrating delay loop... 2241.08 BogoMIPS
> > > CPU3: CPU has booted.
> > > Starting migration thread for cpu 3
> 
> Perhaps we could drop printing the number of virtual/physical address
> bits, and the frequency&ratio information (or maybe just print if they
> are different from the boot cpu ... which would most likely surprise
> the kernel in bad ways, and thus be worthy of printing).  That would
> cut another two lines for all bar one cpu.

Do we need the CPU has booted message?  If it fails to boot, we get
notified.  Can we leave it at that?

As far as I can tell, the nasid and slice is fairly useless.  It might
be helpful, but there should be more user accessible ways of determining
the topology than using boot messages.

The BogoMIPS is another which I would think could be eliminated unless
it is significantly different from the boot cpu.  Maybe say greater
than 10% different.

With these, the boot has been reduced to one migration thread message
when a cpu starts and I believe two lines when one fails to start.
