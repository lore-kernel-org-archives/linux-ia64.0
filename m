From: Thomas Gleixner <tglx@linutronix.de>
Date: Thu, 09 Aug 2007 18:52:13 +0000
Subject: RE: need NOTES in vmlinux.lds.S
Message-Id: <1186685533.12828.3.camel@chaos>
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea430708082330o7277cb2el89c7b89f120c9643@mail.gmail.com>
In-Reply-To: <ed5aea430708082330o7277cb2el89c7b89f120c9643@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2007-08-09 at 11:04 -0700, Luck, Tony wrote:
> > Sure, that sounds reasonable.  Updated patch attached.
> > 
> > I tried this patch with Linus' 2.6.23-rc2 tree and the resulting
> > kernel boots fine, though there are some scary-looking error messages:
> 
> These come from some debug code added by Thomas ... adding him to
> this thread so he can see the trace that his code generated ...
> 
> WARNING: at /data/sc/linux-2.6/kernel/irq/resend.c:70 check_irq_resend()

I know. I'm working on a fix for that. The warning message is harmless
and was added to debug the ne2k-pci breakage which was caused by the
delayed irq disable.

	tglx


