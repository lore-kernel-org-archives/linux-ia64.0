From: Sebastian Siewior <bigeasy@linutronix.de>
Date: Fri, 27 Mar 2020 12:14:51 +0000
Subject: Re: [patch V3 03/20] usb: gadget: Use completion interface instead of open coding it
Message-Id: <20200327121451.pxwewr46urt6dmhe@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200321112544.878032781@linutronix.de>
 <20200321113241.043380271@linutronix.de>
 <87blokde3e.fsf@kernel.org>
In-Reply-To: <87blokde3e.fsf@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Felipe Balbi <balbi@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joel Fernandes <joel@joelfernandes.org>, Oleg Nesterov <oleg@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, Logan Gunthorpe <logang@deltatee.com>, Bjorn Helgaas <bhelgaas@google.com>, Kurt Schwemmer <kurt.schwemmer@microsemi.com>, linux-pci@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>, "David S. Miller" <davem@davemloft.net>, linux-wireless@vger.kernel.org, netdev@vger.kernel.org, Darren Hart <dvhart@infradead.org>, Andy Shevchenko <andy@infradead.org>, platform-driver-x86@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, linux-pm@vger.kernel.org, Len Brown <lenb@kernel.org>, linux-acpi@vger.kernel.org, kbuild test robot <lkp@intel.com>, Nick Hu <nickhu@andestech.com>, Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Guo Ren <guoren@kernel.org>, linux-csky@vger.kernel.org, Brian Cain <bcain@codeaurora.org>, linux-hexagon@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Michal Simek <monstr@monstr.eu>, Michael Ellerman <mpe@ellerman.id.au>, Arnd Bergmann <arnd@arndb.de>, Geoff Levand <geoff@infradead.org>, linuxppc-dev@lists.ozlabs.org, "Paul E . McKenney" <paulmck@kernel.org>, Jonathan Corbet <corbet@lwn.net>, Randy Dunlap <rdunlap@infradead.org>, Davidlohr Bueso <dbueso@suse.de>

On 2020-03-25 10:37:57 [+0200], Felipe Balbi wrote:
> Do you want to carry it via your tree? If so:

We would like to do so.

> Acked-by: Felipe Balbi <balbi@kernel.org>

Thank you.

> Otherwise, let me know and I'll pick this patch.

Sebastian
