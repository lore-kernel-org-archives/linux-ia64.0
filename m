From: "Paul E. McKenney" <paulmck@kernel.org>
Date: Wed, 25 Mar 2020 16:39:19 +0000
Subject: Re: Documentation/locking/locktypes: Further clarifications and wordsmithing
Message-Id: <20200325163919.GU19865@paulmck-ThinkPad-P72>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200323025501.GE3199@paulmck-ThinkPad-P72>
 <87r1xhz6qp.fsf@nanos.tec.linutronix.de>
 <20200325002811.GO19865@paulmck-ThinkPad-P72>
 <87wo78y5yy.fsf@nanos.tec.linutronix.de>
 <20200325160212.oavrni7gmzudnczv@linutronix.de>
In-Reply-To: <20200325160212.oavrni7gmzudnczv@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Sebastian Siewior <bigeasy@linutronix.de>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joel Fernandes <joel@joelfernandes.org>, Oleg Nesterov <oleg@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, Jonathan Corbet <corbet@lwn.net>, Randy Dunlap <rdunlap@infradead.org>, Logan Gunthorpe <logang@deltatee.com>, Bjorn Helgaas <bhelgaas@google.com>, Kurt Schwemmer <kurt.schwemmer@microsemi.com>, linux-pci@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Felipe Balbi <balbi@kernel.org>, linux-usb@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>, "David S. Miller" <davem@davemloft.net>, linux-wireless@vger.kernel.org, netdev@vger.kernel.org, Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>, platform-driver-x86@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, linux-pm@vger.kernel.org, Len Brown <lenb@kernel.org>, linux-acpi@vger.kernel.org, kbuild test robot <lkp@intel.com>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guo Ren <guoren@kernel.org>, linux-csky@vger.kernel.org, Brian Cain <bcain@codeaurora.org>, linux-hexagon@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Michal Simek <monstr@monstr.eu>, Michael Ellerman <mpe@ellerman.id.au>, Arnd Bergmann <arnd@arndb.de>, Geoff Levand <geoff@infradead.org>, linuxppc-dev@lists.ozlabs.org, Davidlohr Bueso <dbueso@suse.de>

On Wed, Mar 25, 2020 at 05:02:12PM +0100, Sebastian Siewior wrote:
> On 2020-03-25 13:27:49 [+0100], Thomas Gleixner wrote:
> > The documentation of rw_semaphores is wrong as it claims that the non-owner
> > reader release is not supported by RT. That's just history biased memory
> > distortion.
> > 
> > Split the 'Owner semantics' section up and add separate sections for
> > semaphore and rw_semaphore to reflect reality.
> > 
> > Aside of that the following updates are done:
> > 
> >  - Add pseudo code to document the spinlock state preserving mechanism on
> >    PREEMPT_RT
> > 
> >  - Wordsmith the bitspinlock and lock nesting sections
> > 
> > Co-developed-by: Paul McKenney <paulmck@kernel.org>
> > Signed-off-by: Paul McKenney <paulmck@kernel.org>
> > Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Acked-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> 
> > --- a/Documentation/locking/locktypes.rst
> > +++ b/Documentation/locking/locktypes.rst
> …
> > +rw_semaphore
> > +======
> > +
> > +rw_semaphore is a multiple readers and single writer lock mechanism.
> > +
> > +On non-PREEMPT_RT kernels the implementation is fair, thus preventing
> > +writer starvation.
> > +
> > +rw_semaphore complies by default with the strict owner semantics, but there
> > +exist special-purpose interfaces that allow non-owner release for readers.
> > +These work independent of the kernel configuration.
> 
> This reads funny, could be my English. "This works independent …" maybe?

The "These" refers to "interfaces", which is plural, so "These" rather
than "This".  But yes, it is a bit awkward, because you have to skip
back past "readers", "release", and "non-owner" to find the implied
subject of that last sentence.

So how about this instead, making the implied subject explicit?

rw_semaphore complies by default with the strict owner semantics, but there
exist special-purpose interfaces that allow non-owner release for readers.
These interfaces work independent of the kernel configuration.

							Thanx, Paul
