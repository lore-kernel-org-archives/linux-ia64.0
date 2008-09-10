From: Bernhard Walle <bwalle@suse.de> (by way of Bernhard Walle
Date: Wed, 10 Sep 2008 11:48:05 +0000
Subject: Re: kdump broken on Altix 350
Message-Id: <20080910134805.488b43f9@kepler.site>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080829180302.6e67c26e@halley.suse.de>
	<20080829180531.0524a1e4@halley.suse.de>
	<57C9024A16AD2D4C97DC78E552063EA30A0067D6@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA30A0067D6@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kexec@lists.infradead.org, jlan@sgi.com

* "Luck, Tony" <tony.luck@intel.com> [2008-08-29]: 

> > your commit
> >
> >     commit 10617bbe84628eb18ab5f723d3ba35005adde143
> >     Author: Tony Luck <tony.luck@intel.com>
> >     Date:   Tue Aug 12 10:34:20 2008 -0700
> >
> >     [IA64] Ensure cpu0 can access per-cpu variables in early boot
> > code
> >
> > broke kdump on our Altix 350. I get following early crash in kdump
> > kernel
> 
> Sorry about that.  I'll try to reproduce it here.

I had some discussion about that with Jay Lan that he could not
reproduce that on his machine. We thought it was different config, but
now I can verify that the problem is reproducible here with the default
configuration (plus CONFIG_SATA_VITESSE).


Bernhard
