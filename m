From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 21 Jul 2008 19:11:39 +0000
Subject: Re: [PATCH 0/2] Migrate data off physical pages with corrected
Message-Id: <1216667499.8806.79.camel@lappy>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080718203514.GD29621@sgi.com>
	 <87prpa88iw.fsf@basil.nowhere.org>  <20080720173914.GA9409@sgi.com>
In-Reply-To: <20080720173914.GA9409@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, mingo@elte.hu, tglx@linutronix.de, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Sun, 2008-07-20 at 12:39 -0500, Russ Anderson wrote:
> On Sat, Jul 19, 2008 at 12:37:11PM +0200, Andi Kleen wrote:
> > If you really wanted to do this you probably should hook it up
> > to mcelog's (or the IA64 equivalent) DIMM database
> 
> Is there an IA64 equivalent?  I've looked at the x86_64 mcelog,
> but have not found a IA64 version.

There's a bit in the SAL error record that can tell you when the
platform thinks the page should be deallocated.  In the section header
(B2.2), ERROR_RECOVERY_INFO, bit 3 "Error threshold exceeded".  If you
use this bit, then it's a platform decision.  If you want pages to be
deallocated on the first hit, then have your SAL always set that bit.  I
believe HP systems do implement this bit in SAL using some kind of
heuristics.

	Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

