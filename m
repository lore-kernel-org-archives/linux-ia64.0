From: David Brownell <david-b@pacbell.net>
Date: Wed, 10 Mar 2004 02:53:58 +0000
Subject: Re: [linux-usb-devel] Re: serious 2.6 bug in USB subsystem?
Message-Id: <404E8346.4070405@pacbell.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20031028013013.GA3991@kroah.com>	<200310280300.h9S30Hkw003073@napali.hpl.hp.com>	<3FA12A2E.4090308@pacbell.net>	<16289.29015.81760.774530@napali.hpl.hp.com>	<16289.55171.278494.17172@napali.hpl.hp.com>	<3FA28C9A.5010608@pacbell.net>	<16457.12968.365287.561596@napali.hpl.hp.com>	<404959A5.6040809@pacbell.net>	<16457.26208.980359.82768@napali.hpl.hp.com>	<4049FE57.2060809@pacbell.net>	<20040308061802.GA25960@cup.hp.com>	<16460.49761.482020.911821@napali.hpl.hp.com>	<404CEA36.2000903@pacbell.net>	<16461.35657.188807.501072@napali.hpl.hp.com>	<404E00B5.5060603@pacbell.net>	<16462.1463.686711.622754@napali.hpl.hp.com>	<404E2B98.6080901@pacbell.net> <16462.21505.526926.903904@napali.hpl.hp.com>
In-Reply-To: <16462.21505.526926.903904@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: Grant Grundler <iod00d@hp.com>, Greg KH <greg@kroah.com>, vojtech@suse.cz, linux-usb-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, pochini@shiny.it

David Mosberger wrote:

> Anyhow, I have been wondering since about Sunday whether it's really
> safe to write HcControlHeadED (and HcBulkHeadED) with 0.  The register
> description itself is ambiguous.  Now I'm finding that Figure 6-5
> "List Service Flow" and Section 6.4.2.2 "Locating Endpoint
> Descriptors" are outright contradictory!

OHCI isn't as tightly specified as one might like.  There are also
differences in how vendors implemented it (notably initialization);
but at least there don't seem to be major incompatibilities that
crept in between implementations.


> So, if the HC behaves as described in the text, then there is an
> obvious race:
> ....
> So I changed ohci-q.c ... to this:
> 
> 	if (ed->ed_prev = NULL) {
> 		if (!ed->hwNextED) {
> 			ohci->hc_control &= ~OHCI_CTRL_CLE;
> 			writel (ohci->hc_control, &ohci->regs->control);
> 		} else

(added the ELSE)

> 			writel (le32_to_cpup (&ed->hwNextED),
> 				&ohci->regs->ed_controlhead);
> 	} else ...
> 
> and now there are no more crashes when plugging in the BTC keyboard.

Interesting.  I had those "else"s in the patch I was testing too,
and they were literally the last "is this really needed?" change I
removed before posting that patch yesterday.  I had tested it on
four different implementations of OHCI (two on SMP) and the "else"
didn't make a difference ... as it might not, given the race
you identified.   This is a good example of something better
found with a fresh set of eyes looking at spec and code!

Looks like that's really needed then!  Whose OHCI silicon are
you testing with, by the way?  Good catch, regardless.

- Dave



