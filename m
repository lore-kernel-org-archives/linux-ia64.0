From: Mark Maule <maule@sgi.com>
Date: Mon, 07 Mar 2005 17:02:38 +0000
Subject: Re: PCI Express
Message-Id: <Pine.SGI.3.96.1050307110123.30397821H-100000@daisy-e236.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Mon, 7 Mar 2005, Matthew Wilcox wrote:

> On Mon, Mar 07, 2005 at 08:48:13AM -0800, Grant Grundler wrote:
> > On Fri, Mar 04, 2005 at 05:42:08PM -0600, Colin Ngam wrote:
> > > Are PCIE devices supported in ia64?
> > 
> > I'm having trouble with the word "supported".
> > You have a PCI-E Bridge and firmware that can talk to it
> > hooked up to an ia64 box?
> > 
> > Anyway, linux has some PCI-E support in the generic PCI code.
> 
> ... and I wrote the ia64-specific bits to access extended PCI config space
> through the SAL PCI accessors.  See PCI_SAL_EXT_ADDRESS().
> 
> Various PCIe features are in the process of being added.  It all depends
> what you mean when you say "supported".
> 

Are there specific lists (other than this one) to be watching for
PCIe discussions?

thanks
Mark

