From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 11 Mar 2004 05:35:41 +0000
Subject: Re: [linux-usb-devel] Re: serious 2.6 bug in USB subsystem?
Message-Id: <16463.64173.334000.250278@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20031028013013.GA3991@kroah.com>
	<200310280300.h9S30Hkw003073@napali.hpl.hp.com>
	<3FA12A2E.4090308@pacbell.net>
	<16289.29015.81760.774530@napali.hpl.hp.com>
	<16289.55171.278494.17172@napali.hpl.hp.com>
	<3FA28C9A.5010608@pacbell.net>
	<16457.12968.365287.561596@napali.hpl.hp.com>
	<404959A5.6040809@pacbell.net>
	<16457.26208.980359.82768@napali.hpl.hp.com>
	<4049FE57.2060809@pacbell.net>
	<20040308061802.GA25960@cup.hp.com>
	<16460.49761.482020.911821@napali.hpl.hp.com>
	<404CEA36.2000903@pacbell.net>
	<16461.35657.188807.501072@napali.hpl.hp.com>
	<404E00B5.5060603@pacbell.net>
	<16462.1463.686711.622754@napali.hpl.hp.com>
	<404E2B98.6080901@pacbell.net>
	<16462.48341.393442.583311@napali.hpl.hp.com>
	<404F40C2.3080003@pacbell.net>
	<16463.22710.230252.777998@napali.hpl.hp.com>
	<404FD24D.1070200@pacbell.net>
In-Reply-To: <404FD24D.1070200@pacbell.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Brownell <david-b@pacbell.net>
Cc: davidm@hpl.hp.com, Grant Grundler <iod00d@hp.com>, Greg KH <greg@kroah.com>, vojtech@suse.cz, linux-usb-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, pochini@shiny.it

>>>>> On Wed, 10 Mar 2004 18:43:25 -0800, David Brownell <david-b@pacbell.net> said:

  David.B> David Mosberger wrote:

  >> The current OHCI relies on the internals of the dma_pool()
  >> implementation.  ...

  David.B> It'd be good if you said _how_ you think it relies on such
  David.B> internals.

  >>  I thought I did.  Suppose somebody changed the dma_pool code
  >> such that it would overwrite freed memory with an
  >> 0xf00000000000000 pattern.

  David.B> Erm, _anything_ the dma_pool code does with freed memory is
  David.B> legal.

Glad to see we agree on that!

  David.B> Anyway, please (a) see if 2.6.4 works for you, and (b)
  David.B> direct any future followups on this thread _only_ to
  David.B> linux-usb-devel.

The patch that's in 2.6.4 definitely looks like a step in the right
direction.  I still have some concerns.  I'll follow up on
linux-usb-devel with more details.

Thanks,

	--david
