From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 10 Mar 2004 06:11:11 +0000
Subject: Re: [linux-usb-devel] Re: serious 2.6 bug in USB subsystem?
Message-Id: <16462.45439.232398.947647@napali.hpl.hp.com>
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
	<16462.21505.526926.903904@napali.hpl.hp.com>
	<404E8346.4070405@pacbell.net>
In-Reply-To: <404E8346.4070405@pacbell.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Brownell <david-b@pacbell.net>
Cc: davidm@hpl.hp.com, Grant Grundler <iod00d@hp.com>, Greg KH <greg@kroah.com>, vojtech@suse.cz, linux-usb-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, pochini@shiny.it

>>>>> On Tue, 09 Mar 2004 18:53:58 -0800, David Brownell <david-b@pacbell.net> said:

  David.B> Whose OHCI silicon David.B> are you testing with, by the way?

lspci claims it's a NEC chip:

a0:01.0 USB Controller: NEC Corporation USB (rev 41) (prog-if 10 [OHCI])
        Subsystem: NEC Corporation USB
        Flags: bus master, medium devsel, latency 128, IRQ 62
        Memory at 00000000d0062000 (32-bit, non-prefetchable) [size=4K]
        Capabilities: <available only to root>

  --david
