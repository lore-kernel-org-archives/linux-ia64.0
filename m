From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 27 Aug 2010 17:16:29 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <201008271916.30369.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz> <987664A83D2D224EAE907B061CE93D53015D91D029@orsmsx505.amr.corp.intel.com>
In-Reply-To: <987664A83D2D224EAE907B061CE93D53015D91D029@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hedi Berriche <hedi@sgi.com>

On Friday 27 of August 2010 18:08:03 Luck, Tony wrote:
> > Hedi Berriche sent me a simple test case that can
> > trigger the failure on the siglock.
>
> Can you post the test case please. How long does it typically take
> to reproduce the problem?

I let Hedi send it. It's really easy to reproduce. In fact, I can reproduce it 
within 5 minutes on an 8-CPU system.

> > Next, CPU 5 releases the spinlock with st2.rel, changing the lock
> > value to 0x0 (correct).
> >
> > SO FAR SO GOOD.
> >
> > Now, CPU 4, CPU 5 and CPU 7 all want to acquire the lock again.
> > Interestingly, CPU 5 and CPU 7 are both granted the same ticket,
>
> What is the duplicate ticket number that CPUs 5 & 7 get at this point?
> Presumably 0x0, yes? Or do they see a stale 0x7fff?

They get a zero, yes.
> > and the spinlock value (as seen from the debug fault handler) is
> > 0x0 after single-stepping over the fetchadd4.acq, in both cases.
> > CPU 4 correctly sets the spinlock value to 0x1.
>
> Is the fault handler using "ld.acq" to look at the spinlock value?
> If not, then this might be a red herring. [Though clearly something
> bad is going on here].

Right. I also realized I was reading the spinlock value with a plain "ld4". 
When I changed it to "ld4.acq", this is what happens:

1. We're in _spin_lock_irq, which starts like this:

0xa0000001008ea000 <_spin_lock_irq>:    [MMI]       rsm 0x4000;;
0xa0000001008ea001 <_spin_lock_irq+1>:              fetchadd4.acq r15=[r32],1
0xa0000001008ea002 <_spin_lock_irq+2>:              nop.i 0x0;;

AFAICS the spinlock value should be 0x0 (after having wrapped around from 
0xffff0000 at release on the same CPU).

2. fetchadd4.acq generates a debug exception (because it writes to the watched 
location)
3. ld4.acq inside the debug fault handler reads 0x0 from the location
4. the handler sets PSR.ss on return
5. fetchadd4.acq puts 0x1 (why?) in r15 and generates a Single step fault
6. the fault handler now reads 0x0 (sic!) from the spinlock location (again, 
using ld4.acq)
7. the resulting kernel crash dump contains ZERO in the spinlock location

Maybe, there's something wrong with my test module, because I'm already 
getting tired today, but there's definitely something wrong here. I'll try to 
polish it and send here later.

> > Any ideas?
>
> What cpu model are you running on?
> What is the topological connection between CPU 4, 5 and 7 - are any of
> them hyper-threaded siblings? Cores on same socket? N.B. topology may
> change from boot to boot, so you may need to capture /proc/cpuinfo from
> the same boot where this problem is detected. But the variation is
> usually limited to which socket gets to own logical cpu 0.

There are two Dual-Core Intel(R) Itanium(R) 2 Processor 9150M in the test 
machine:

physical package 0
  core 0: CPU 0, CPU 4
  core 1: CPU 2, CPU 6

physical package 196611
  core 0: CPU 1, CPU 5
  core 1: CPU 3, CPU 7

/proc/cpuinfo says:

processor  : 0
vendor     : GenuineIntel
arch       : IA-64
family     : 32
model      : 1
model name : Dual-Core Intel(R) Itanium(R) 2 Processor 9150M
revision   : 1
archrev    : 0
features   : branchlong, 16-byte atomic ops
cpu number : 0
cpu regs   : 4
cpu MHz    : 1668.672
itc MHz    : 416.667500
BogoMIPS   : 1662.97
siblings   : 4
physical id: 0
core id    : 0
thread id  : 0

processor  : 1
vendor     : GenuineIntel
arch       : IA-64
family     : 32
model      : 1
model name : Dual-Core Intel(R) Itanium(R) 2 Processor 9150M
revision   : 1
archrev    : 0
features   : branchlong, 16-byte atomic ops
cpu number : 0
cpu regs   : 4
cpu MHz    : 1668.672
itc MHz    : 416.667500
BogoMIPS   : 1662.97
siblings   : 4
physical id: 196611
core id    : 0
thread id  : 0

processor  : 2
vendor     : GenuineIntel
arch       : IA-64
family     : 32
model      : 1
model name : Dual-Core Intel(R) Itanium(R) 2 Processor 9150M
revision   : 1
archrev    : 0
features   : branchlong, 16-byte atomic ops
cpu number : 0
cpu regs   : 4
cpu MHz    : 1668.672
itc MHz    : 416.667500
BogoMIPS   : 1662.97
siblings   : 4
physical id: 0
core id    : 1
thread id  : 0

processor  : 3
vendor     : GenuineIntel
arch       : IA-64
family     : 32
model      : 1
model name : Dual-Core Intel(R) Itanium(R) 2 Processor 9150M
revision   : 1
archrev    : 0
features   : branchlong, 16-byte atomic ops
cpu number : 0
cpu regs   : 4
cpu MHz    : 1668.672
itc MHz    : 416.667500
BogoMIPS   : 1662.97
siblings   : 4
physical id: 196611
core id    : 1
thread id  : 0

processor  : 4
vendor     : GenuineIntel
arch       : IA-64
family     : 32
model      : 1
model name : Dual-Core Intel(R) Itanium(R) 2 Processor 9150M
revision   : 1
archrev    : 0
features   : branchlong, 16-byte atomic ops
cpu number : 0
cpu regs   : 4
cpu MHz    : 1668.672
itc MHz    : 416.667500
BogoMIPS   : 1662.97
siblings   : 4
physical id: 0
core id    : 0
thread id  : 1

processor  : 5
vendor     : GenuineIntel
arch       : IA-64
family     : 32
model      : 1
model name : Dual-Core Intel(R) Itanium(R) 2 Processor 9150M
revision   : 1
archrev    : 0
features   : branchlong, 16-byte atomic ops
cpu number : 0
cpu regs   : 4
cpu MHz    : 1668.672
itc MHz    : 416.667500
BogoMIPS   : 1662.97
siblings   : 4
physical id: 196611
core id    : 0
thread id  : 1

processor  : 6
vendor     : GenuineIntel
arch       : IA-64
family     : 32
model      : 1
model name : Dual-Core Intel(R) Itanium(R) 2 Processor 9150M
revision   : 1
archrev    : 0
features   : branchlong, 16-byte atomic ops
cpu number : 0
cpu regs   : 4
cpu MHz    : 1668.672
itc MHz    : 416.667500
BogoMIPS   : 1662.97
siblings   : 4
physical id: 0
core id    : 1
thread id  : 1

processor  : 7
vendor     : GenuineIntel
arch       : IA-64
family     : 32
model      : 1
model name : Dual-Core Intel(R) Itanium(R) 2 Processor 9150M
revision   : 1
archrev    : 0
features   : branchlong, 16-byte atomic ops
cpu number : 0
cpu regs   : 4
cpu MHz    : 1668.672
itc MHz    : 416.667500
BogoMIPS   : 1662.97
siblings   : 4
physical id: 196611
core id    : 1
thread id  : 1

Petr Tesarik
