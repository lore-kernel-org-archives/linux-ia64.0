From: "H . J . Lu" <hjl@valinux.com>
Date: Mon, 11 Sep 2000 21:19:08 +0000
Subject: Re: [Linux-ia64] possible bug in the efi real time clock
Message-Id: <marc-linux-ia64-105590678205488@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205465@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205465@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Sep 09, 2000 at 12:51:03PM -0700, Uros Prestor wrote:
> Stephane Eranian wrote:
> 
> > > On the BigSur B1 stepping with BIOS 60 machine, it crashes when running
> > > the hwclock.  Could it be a bug in the efi real time clock?
> > >
> > Hard to tell from this description. Could you give more details
> > like what does appear on the screen ? Could you capture the "tombstone"
> > (regs dump) and send it to me. I don't have a Bigsur B1 so I can't
> > really reproduce the problem.
> 
> What happens is a complete system lockup.  There is no kernel register dump,
> panic or oops.  The screen just goes blank.  You can lock up the box by
> simply running /sbin/hwclock.
> 

In my case, /sbin/hwclock causes the instant reboot on B1 BigSur and
it crashes so bad that I have to unplug the power cord to get my
machine back. B1 stepping is quite different than A2 stepping on
BigSur, even with the same BIOS, Build 59.


H.J.

