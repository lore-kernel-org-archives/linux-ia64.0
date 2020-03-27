From: Geoff Levand <geoff@infradead.org>
Date: Fri, 27 Mar 2020 19:14:43 +0000
Subject: Re: [patch V3 12/20] powerpc/ps3: Convert half completion to rcuwait
Message-Id: <f3210d53-dfb1-6bbc-cc82-832105fcfaa2@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200321112544.878032781@linutronix.de>
 <20200321113241.930037873@linutronix.de>
In-Reply-To: <20200321113241.930037873@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Sebastian Siewior <bigeasy@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Joel Fernandes <joel@joelfernandes.org>, Oleg Nesterov <oleg@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, Michael Ellerman <mpe@ellerman.id.au>, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, Logan Gunthorpe <logang@deltatee.com>, Bjorn Helgaas <bhelgaas@google.com>, Kurt Schwemmer <kurt.schwemmer@microsemi.com>, linux-pci@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Felipe Balbi <balbi@kernel.org>, linux-usb@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>, "David S. Miller" <davem@davemloft.net>, linux-wireless@vger.kernel.org, netdev@vger.kernel.org, Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>, platform-driver-x86@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, linux-pm@vger.kernel.org, Len Brown <lenb@kernel.org>, linux-acpi@vger.kernel.org, kbuild test robot <lkp@intel.com>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guo Ren <guoren@kernel.org>, linux-csky@vger.kernel.org, Brian Cain <bcain@codeaurora.org>, linux-hexagon@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Michal Simek <monstr@monstr.eu>, "Paul E . McKenney" <paulmck@kernel.org>, Jonathan Corbet <corbet@lwn.net>, Randy Dunlap <rdunlap@infradead.org>, Davidlohr Bueso <dbueso@suse.de>

Hi,

On 3/21/20 4:25 AM, Thomas Gleixner wrote:
> From: Thomas Gleixner <tglx@linutronix.de>
> 
> The PS3 notification interrupt and kthread use a hacked up completion to
> communicate. Since we're wanting to change the completion implementation and
> this is abuse anyway, replace it with a simple rcuwait since there is only ever
> the one waiter.
> 
> AFAICT the kthread uses TASK_INTERRUPTIBLE to not increase loadavg, kthreads
> cannot receive signals by default and this one doesn't look different. Use
> TASK_IDLE instead.

I tested the patch set applied against v5.6-rc7 on the PS3 and it worked
as expected.

Tested by: Geoff Levand <geoff@infradead.org>
