From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 08 Mar 2004 18:58:41 +0000
Subject: Re: [linux-usb-devel] Re: serious 2.6 bug in USB subsystem?
Message-Id: <16460.49761.482020.911821@napali.hpl.hp.com>
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
In-Reply-To: <20040308061802.GA25960@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: David Brownell <david-b@pacbell.net>, davidm@hpl.hp.com, Greg KH <greg@kroah.com>, vojtech@suse.cz, linux-usb-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, pochini@shiny.it

>>>>> On Sun, 7 Mar 2004 22:18:02 -0800, Grant Grundler <iod00d@hp.com> said:

  >> `Such a write-buffering mechanism is clearly a type of
  >> (write-)caching effect,

  Grant> No - the data is still in flight and in some deterministic
  Grant> time frame will become visible to the CPU.  Calling it a
  Grant> "caching effect" confuses the issues even worse.

That's why I'm so unhappy that the PCI interface used the term
"consistent" memory, when it should have said "coherent".  We
should nail a plate on everbody's forehead saying:

 consistency = coherency + ordering

Perhaps then people would start to have a clear distincition between
the meaning of the two terms (or at least it would force them to think
about it! ;-).

But in any case, as later experimentation confirmed, the USB bug isn't
(just) an ordering issue.  The order of operation described in the
OHCI spec does not rely on any specific order of interrupt delivery at
all, so I was wrong about that.

	--david
