From: Robin Holt <holt@sgi.com>
Date: Thu, 19 Aug 2004 18:18:03 +0000
Subject: Re: calling oem sal functions
Message-Id: <20040819181803.GA1313@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4124E222.2080105@intel.com>
In-Reply-To: <4124E222.2080105@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Aug 19, 2004 at 06:29:04PM +0100, Christoph Hellwig wrote:
> On Thu, Aug 19, 2004 at 05:23:46PM +0000, Tony Luck wrote:
> > Dean,
> > 
> > I've been thinking about this, and it does seem unresonable that there
> > is no way for an OEM written module to make a call to an OEM SAL function.
> > 
> > Would something like the (compiles, but untested) attached patch work
> > for you?  The return value of 0/-1 just indicates whether the SAL call
> > was attempted.  Callers should look at the status field of the isrvp
> > structure to determine the actual success of the call.
> > 
> > Would you also need "_nolock" and "_reentrant" versions?
> 
> Please make the exports _GPL so we have the callers under rcontrol.

If you make them GPL, it makes the call useless to SGI.  Some of our
tests suites have the problem description we are testing for and the
resolution.  This may include vendor specific or customer specific
data which is not disclosable.  Some of the vendor specific tests are
likewise covered by NDA.  I understand you would love to have
everything _GPL, but that is unreasonable.

All that is being provided here is a gateway to SAL.  How much value
is the kernel community adding.

Tony, please carefully consider the _GPL.

Thanks,
Robin Holt
