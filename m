From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 06 Apr 2004 23:15:44 +0000
Subject: Re: [PATCH] don't offer GEN_RTC on ia64
Message-Id: <16499.14880.938413.166692@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404061622.49260.bjorn.helgaas@hp.com>
	<20040406223416.GH31152@smtp.west.cox.net>
	<200404061637.48475.bjorn.helgaas@hp.com>
In-Reply-To: <200404061637.48475.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Tom Rini <trini@kernel.crashing.org>, Andrew Morton <akpm@osdl.org>, p_gortmaker@yahoo.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> On Tue, 6 Apr 2004 16:37:48 -0600, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> I'd actually like to do that, but that's a longer-term
  Bjorn> project.  And I don't know the history behind efi_rtc, so
  Bjorn> maybe there's a good reason for it being separate.

AFAIR, when efirtc was being written, the normal RTC driver was
specific to the PC clock chips (mc14whatever) and it wasn't clear
whether it should even try to be generic.  I don't think anybody is
particularly attached to the bits.

	--david
