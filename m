From: "John Lee" <jlee@platsolns.com>
Date: Thu, 19 Aug 2004 22:14:20 +0000
Subject: RE: calling oem sal functions
Message-Id: <AEBB9AF2F7713A4FAB1397435451162E980485@spock.invent.psi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4124E222.2080105@intel.com>
In-Reply-To: <4124E222.2080105@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org 
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Robin Holt
...
> 
> On Thu, Aug 19, 2004 at 06:29:04PM +0100, Christoph Hellwig wrote:
> > On Thu, Aug 19, 2004 at 05:23:46PM +0000, Tony Luck wrote:
....
> > > 
> > > Would you also need "_nolock" and "_reentrant" versions?

Yes, that would be perfect.

> > 
> > Please make the exports _GPL so we have the callers under rcontrol.
> 
> If you make them GPL, it makes the call useless to SGI.  Some of our
> tests suites have the problem description we are testing for and the
> resolution.  This may include vendor specific or customer specific
> data which is not disclosable.  Some of the vendor specific tests are
> likewise covered by NDA.  I understand you would love to have
> everything _GPL, but that is unreasonable.
> 
> All that is being provided here is a gateway to SAL.  How much value
> is the kernel community adding.
> 
> Tony, please carefully consider the _GPL.
> 

I have to second to this.

John
Platform Solutions
