From: Thomas Gleixner <tglx@linutronix.de>
Date: Sat, 21 Mar 2020 17:45:38 +0000
Subject: Re: [patch V3 00/20] Lock ordering documentation and annotation for lockdep
Message-Id: <87mu89r48t.fsf@nanos.tec.linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200321112544.878032781@linutronix.de> <20200321171902.xxlnpikc65wd3b4m@linux-p48b>
In-Reply-To: <20200321171902.xxlnpikc65wd3b4m@linux-p48b>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Sebastian Siewior <bigeasy@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Joel Fernandes <joel@joelfernandes.org>, Oleg Nesterov <oleg@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, Bjorn Helgaas <bhelgaas@google.com>, Kurt Schwemmer <kurt.schwemmer@microsemi.com>, linux-pci@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Felipe Balbi <balbi@kernel.org>, linux-usb@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>, "David S. Miller" <davem@davemloft.net>, linux-wireless@vger.kernel.org, netdev@vger.kernel.org, Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>, platform-driver-x86@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, linux-pm@vger.kernel.org, Len Brown <lenb@kernel.org>, linux-acpi@vger.kernel.org, kbuild test robot <lkp@intel.com>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guo Ren <guoren@kernel.org>, linux-csky@vger.kernel.org, Brian Cain <bcain@codeaurora.org>, linux-hexagon@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Michal Simek <monstr@monstr.eu>, Michael Ellerman <mpe@ellerman.id.au>, Arnd Bergmann <arnd@arndb.de>, Geoff Levand <geoff@infradead.org>, linuxppc-dev@lists.ozlabs.org, "Paul E . McKenney" <paulmck@kernel.org>, Jonathan Corbet <corbet@lwn.net>, Randy Dunlap <rdunlap@infradead.org>, Davidlohr Bueso <dbueso@suse.de>

Davidlohr Bueso <dave@stgolabs.net> writes:

> On Sat, 21 Mar 2020, Thomas Gleixner wrote:
>
>>This is the third and hopefully final version of this work. The second one
>>can be found here:
>
> Would you rather I send in a separate series with the kvm changes, or
> should I just send a v2 with the fixes here again?

Send a separate series please. These nested threads are hard to follow.

Thanks,

        tglx
