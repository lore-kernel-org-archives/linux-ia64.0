From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 15 Jan 2004 22:56:58 +0000
Subject: Re: [PATCH] readX_relaxed interface
Message-Id: <20040115225658.GA9389@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040115204913.GA8172@sgi.com> <20040115221640.GA11283@cup.hp.com>
In-Reply-To: <20040115221640.GA11283@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, jeremy@sgi.com

On Thu, Jan 15, 2004 at 02:16:40PM -0800, Grant Grundler wrote:
> Outside the context of PCI-X Relaxed Ordering, this violates PCI
> ordering rules. Any patches to drivers *using* the new readb()
> variants in effect work around this violation. I"m ok with that - just
> want it to be clear.

Yep, that's an advantage of this API--you only use it when you know it's
ok to violate those rules.

> PCI-X support will need a different interface
> (eg pcix_enable_relaxed_ordering()) to support
> it's form of "Relaxed Ordering".

Right, seperate issue.

> > If it looks ok, I'll add in macros for the other arches and send it out
> > for inclusion.
> 
> It looks ok to me.

Great, thanks.

Jesse
