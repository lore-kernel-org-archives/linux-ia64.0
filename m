From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Sun, 10 Sep 2000 04:21:51 +0000
Subject: Re: [Linux-ia64] possible bug in the efi real time clock
Message-Id: <marc-linux-ia64-105590678205480@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205465@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205465@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Uros,

> > > On the BigSur B1 stepping with BIOS 60 machine, it crashes when running
> > > the hwclock.  Could it be a bug in the efi real time clock?
> > >

Our 4-way A3 with Build50 is showing similar behavior. However the system 
is up and running fine with test8.

I looked at the efirtc driver one more time. The ioctl() to read the clock
fails because EFI.GetTime() returns an error. This is new to me. I need to
investigate why it is so. The reason why /proc/efirtc does not fails is
because of a missing test on the return values of the 2 EFI calls to read
the time. You get random results back. I will fix this today. 

I am suspecting something is wrong in EFI with Build50 and up.

> I think this symptom was around for a long time.  On pretty much all the
> distributions we shipped you could observe a brief video glitch during the
> boot when the system was setting hardware clock.  Usually, the screen would
> go blank for a split second and then get switched on again.  Why this would
> happen while running hwclock is beyond me.  I do recall somebody with a Lion
> system observing a hard lockup.  The workaround was to disable running
> hwclock on boot.  Nobody here had time to poke around what was going on,
> though.
> 
I saw this thing too recently on an A2 with Build59 but the system works
fine.

--Stephane


