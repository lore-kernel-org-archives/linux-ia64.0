From: Russell King <rmk@arm.linux.org.uk>
Date: Sat, 10 Apr 2004 08:28:06 +0000
Subject: Re: [PATCH] early serial console support
Message-Id: <20040410092806.A32143@flint.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404011521.16402.bjorn.helgaas@hp.com>
In-Reply-To: <200404011521.16402.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Apr 01, 2004 at 11:34:16PM +0100, Matthew Wilcox wrote:
> On Thu, Apr 01, 2004 at 03:21:16PM -0700, Bjorn Helgaas wrote:
> > +	/*
> > +	 * The presence of an HCDP entry does not imply that we should
> > +	 * use a serial console.
> > +	 */
> > +	if (!strstr(cmdline, "console=serial"))
> > +		return;
> 
> Yes, but ... it's legal to say "console=tty,serial".  So perhaps we need
> something like ...

Are you sure that's legal?  The existing console= parameter format is:

	console=<device>[,<device-specific-parameters>]

in which case, the parameter you've given above indicates:

	device = tty
	device-specific-params = serial

which is obviously nonsense.  I think it should be:

	console=tty console=serial

which nicely fits into the current scheme.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
