From: David Brownell <david-b@pacbell.net>
Date: Thu, 11 Mar 2004 02:43:25 +0000
Subject: Re: [linux-usb-devel] Re: serious 2.6 bug in USB subsystem?
Message-Id: <404FD24D.1070200@pacbell.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20031028013013.GA3991@kroah.com>	<200310280300.h9S30Hkw003073@napali.hpl.hp.com>	<3FA12A2E.4090308@pacbell.net>	<16289.29015.81760.774530@napali.hpl.hp.com>	<16289.55171.278494.17172@napali.hpl.hp.com>	<3FA28C9A.5010608@pacbell.net>	<16457.12968.365287.561596@napali.hpl.hp.com>	<404959A5.6040809@pacbell.net>	<16457.26208.980359.82768@napali.hpl.hp.com>	<4049FE57.2060809@pacbell.net>	<20040308061802.GA25960@cup.hp.com>	<16460.49761.482020.911821@napali.hpl.hp.com>	<404CEA36.2000903@pacbell.net>	<16461.35657.188807.501072@napali.hpl.hp.com>	<404E00B5.5060603@pacbell.net>	<16462.1463.686711.622754@napali.hpl.hp.com>	<404E2B98.6080901@pacbell.net>	<16462.48341.393442.583311@napali.hpl.hp.com>	<404F40C2.3080003@pacbell.net> <16463.22710.230252.777998@napali.hpl.hp.com>
In-Reply-To: <16463.22710.230252.777998@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: Grant Grundler <iod00d@hp.com>, Greg KH <greg@kroah.com>, vojtech@suse.cz, linux-usb-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, pochini@shiny.it

David Mosberger wrote:

>   >> The current OHCI relies on the internals of the dma_pool()
>   >> implementation.  ...
>   David.B> It'd be good if you said _how_ you think it relies on such
>   David.B> internals.
> 
> I thought I did.  Suppose somebody changed the dma_pool code such that
> it would overwrite freed memory with an 0xf00000000000000 pattern. 

Erm, _anything_ the dma_pool code does with freed memory is legal.
Even the old "monkeys flying out of the back of the server" trick!  :)


Anyway, please (a) see if 2.6.4 works for you, and (b) direct any
future followups on this thread _only_ to linux-usb-devel.

- Dave


