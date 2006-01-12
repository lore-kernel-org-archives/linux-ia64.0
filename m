From: Paul Mackerras <paulus@samba.org>
Date: Thu, 12 Jan 2006 05:47:27 +0000
Subject: Re: [PATCH 1/3] msi vector targeting abstractions
Message-Id: <17349.60783.236661.875374@cargo.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060111155251.12460.71269.12163@attica.americas.sgi.com>
	<20060111155256.12460.26048.32596@attica.americas.sgi.com>
	<20060112050243.GC332@colo.lackof.org>
In-Reply-To: <20060112050243.GC332@colo.lackof.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <grundler@parisc-linux.org>
Cc: Mark Maule <maule@sgi.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, gregkh@suse.de, linux-kernel@vger.kernel.org, linuxppc64-dev@ozlabs.org, linux-pci@atrey.karlin.mff.cuni.cz

Grant Grundler writes:

> > +	if ((status = msi_arch_init()) < 0) {
> 
> Willy told me I should always complain about assignment in if() statements :)

We are getting incredibly politically correct these days, aren't we.

I see nothing wrong with that if statement.  It's perfectly valid,
idiomatic C.  You can ignore Willy if you like. :)

(I would look askance at something that did an assignment as one of
the parameters of a procedure call in an if statement, though.)

Paul.
