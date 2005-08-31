From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 31 Aug 2005 16:24:07 +0000
Subject: Re: 2.6.13 does not boot on Eiger
Message-Id: <200508311024.07763.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <jefysr9gc7.fsf@sykes.suse.de>
In-Reply-To: <jefysr9gc7.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 31 August 2005 10:03 am, Bjorn Helgaas wrote:
> I used your .config and saw an MCA in i8042_flush() (IIP in
> __ia64_inb, BR0 in i8042_flush).  Can you try turning off
> CONFIG_SERIO_I8042?  This was fixed a while back, but maybe
> it got broken again.

Oh, I remember now.  I debugged this a while back.  The i8042
fix was originally done in terms of ACPI, but recently changed
to be PNP-based.  So on ia64, we need CONFIG_PNP and CONFIG_PNPACPI.

These are turned off in your .config (and in all the configs in
the tree).  I'll post a patch to fix those.
