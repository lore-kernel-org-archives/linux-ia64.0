From: Uros Prestor <uros@turbolinux.com>
Date: Sat, 09 Sep 2000 19:51:03 +0000
Subject: Re: [Linux-ia64] possible bug in the efi real time clock
Message-Id: <marc-linux-ia64-105590678205470@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205465@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205465@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane Eranian wrote:

> > On the BigSur B1 stepping with BIOS 60 machine, it crashes when running
> > the hwclock.  Could it be a bug in the efi real time clock?
> >
> Hard to tell from this description. Could you give more details
> like what does appear on the screen ? Could you capture the "tombstone"
> (regs dump) and send it to me. I don't have a Bigsur B1 so I can't
> really reproduce the problem.

What happens is a complete system lockup.  There is no kernel register dump,
panic or oops.  The screen just goes blank.  You can lock up the box by
simply running /sbin/hwclock.

I think this symptom was around for a long time.  On pretty much all the
distributions we shipped you could observe a brief video glitch during the
boot when the system was setting hardware clock.  Usually, the screen would
go blank for a split second and then get switched on again.  Why this would
happen while running hwclock is beyond me.  I do recall somebody with a Lion
system observing a hard lockup.  The workaround was to disable running
hwclock on boot.  Nobody here had time to poke around what was going on,
though.

Uros

--
Uros Prestor
uros@turbolinux.com




