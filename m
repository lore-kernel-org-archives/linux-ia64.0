From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 19 Aug 2004 17:29:04 +0000
Subject: Re: calling oem sal functions
Message-Id: <20040819182904.A11376@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4124E222.2080105@intel.com>
In-Reply-To: <4124E222.2080105@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Aug 19, 2004 at 05:23:46PM +0000, Tony Luck wrote:
> Dean,
> 
> I've been thinking about this, and it does seem unresonable that there
> is no way for an OEM written module to make a call to an OEM SAL function.
> 
> Would something like the (compiles, but untested) attached patch work
> for you?  The return value of 0/-1 just indicates whether the SAL call
> was attempted.  Callers should look at the status field of the isrvp
> structure to determine the actual success of the call.
> 
> Would you also need "_nolock" and "_reentrant" versions?

Please make the exports _GPL so we have the callers under rcontrol.

