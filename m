From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 29 Apr 2004 04:52:46 +0000
Subject: Re: [PATCH] minor processor.h cleanup
Message-Id: <16528.35358.781216.385989@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404281011.38501.bjorn.helgaas@hp.com>
In-Reply-To: <200404281011.38501.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 28 Apr 2004 10:11:38 -0600, Bjorn Helgaas <bjorn.helgaas@HP.COM> said:

  Bjorn> Move PSR.ic clear/restore into ia64_itr().
  Bjorn> Remove ia64_itc(), ia64_ptr(), ia64_set_iva() (unused).

I'm not sure I consider this a cleanup.  The processor.h
inlines/macros were meant to map more or less directly to processor
instructions.  Mucking with psr.ic is quite expensive so it's useful
to be able to batch several things together and not have to toggle
psr.ic every time.  But then again, if we never use it that way, I can
see your point...

	--david
