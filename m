From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 06 Nov 2003 18:56:55 +0000
Subject: RE: [DMESG] cpumask_t in action
Message-Id: <marc-linux-ia64-106814524713112@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106807117402763@msgid-missing>
In-Reply-To: <marc-linux-ia64-106807117402763@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> That'd cut us down to:
> 
> > CPU 3: 61 virtual and 50 physical address bits
> > CPU 3: nasid 2, slice 2, cnode 1
> > CPU 3: base freq 0.000MHz, ITC ratio/2, ITC freq00.000MHz+/--1ppm
> > Calibrating delay loop... 2241.08 BogoMIPS
> > CPU3: CPU has booted.
> > Starting migration thread for cpu 3

Perhaps we could drop printing the number of virtual/physical address
bits, and the frequency&ratio information (or maybe just print if they
are different from the boot cpu ... which would most likely surprise
the kernel in bad ways, and thus be worthy of printing).  That would
cut another two lines for all bar one cpu.

-Tony
