From: Horms <horms@verge.net.au>
Date: Sun, 04 Jun 2006 04:57:11 +0000
Subject: Re: IA64: Broken Serial Console
Message-Id: <20060604045709.GA18372@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <44128F9D.7050402@sgi.com> <200603112017.k2BKHcg20412@unix-os.sc.intel.com> <20060310082445.GA18715@verge.net.au> <yq0irqm39r8.fsf@jaguar.mkp.net> <20060311034346.GI11359@verge.net.au> <44128F9D.7050402@sgi.com> <20060313040825.GA31703@verge.net.au> <20060602114805.GA1462@verge.net.au> <20060602115359.GG32143@parisc-linux.org>
In-Reply-To: <20060602115359.GG32143@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-ia64@vger.kernel.org, linux-serial@vger.kernel.org, Bjorn Helgaas <bjorn.helgaas@hp.com>, Russell King <rmk+kernel@arm.linux.org.uk>

On Fri, Jun 02, 2006 at 05:53:59AM -0600, Matthew Wilcox wrote:
> On Fri, Jun 02, 2006 at 08:48:06PM +0900, Horms wrote:
> > I have noticed that the serial console on my ia64 machine seems
> > to have broken since 2.6.16. Thanks to git bisect I have been
> > able to track this problem down to 111c9bf8c5cfa92363b3719c8956d29368b5b9de
> > 
> >   [SERIAL] remove 8250_acpi (replaced by 8250_pnp and PNPACPI)
> > 
> >   With the combination of PNPACPI and 8250_pnp, we no longer need
> >   8250_acpi.
> > 
> >   Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
> >   Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> > 
> > I haven't had time to look into the code and I have to leave
> > my desk shortly, so I thought I would post here to see if anyone
> > has any ideas.
> 
> Well, does your config have PNPACPI and SERIAL_8250_PNP enabled?

Thanks, adding those options (obviously) solved the problem.

-- 
Horms                                           http://www.vergenet.net/~horms/

