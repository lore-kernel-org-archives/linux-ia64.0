From: Jack Steiner <steiner@sgi.com>
Date: Thu, 19 Aug 2004 18:48:00 +0000
Subject: Re: calling oem sal functions
Message-Id: <20040819184800.GB6710@sgi.com>
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

SGI uses OEM_SAL calls in some of it's online diagnostics. These diagnostics
are run on production systems, both in the factory and at customer sites.
If the SAL call interface is marked _GPL, then these diagnostics cant
be run on standard kernels. 

Since the OEM_SAL call interface restricts SAL calls to the OEM range
of function codes, I dont understand why these calls should be GPL'ed.



-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


