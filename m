From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 04 Feb 2004 21:32:12 +0000
Subject: RE: [PATCH] turn off irqdebug by default on Altix
Message-Id: <B05667366EE6204181EABE9C1B1C0EB58024BA@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040204152841.GB3387@localhost>
In-Reply-To: <20040204152841.GB3387@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Don't take me wrong, I do want these irqdebug off too on one of our
large performance setup here as well :-)  Even reading from variable
noirqdebug is costing us some cache misses.  Can this be made compile
time option?  So when it is off, it is really off unless someone need to
turn this debug option on and off dynamically.

- Ken

-----Original Message-----
From: linux-ia64-owner@vger.kernel.org
[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Jack Steiner
Sent: Wednesday, February 04, 2004 11:41 AM
To: Martin Hicks
Cc: Chen, Kenneth W; linux-ia64@vger.kernel.org; akpm@osdl.org;
jbarnes@sgi.com
Subject: Re: [PATCH] turn off irqdebug by default on Altix


On Wed, Feb 04, 2004 at 02:08:05PM -0500, Martin Hicks wrote:
> 
> 
> On Wed, Feb 04, 2004 at 11:04:43AM -0800, Chen, Kenneth W wrote:
> > This is really confusing with two parameters that do the same thing.
> > What will happen if someone pass noirqdebug and irqdebug at the same
> > time?
> > 
> > What's wrong with boot time parameter of noirqdebug?
> 
> It just means that if you forget to pass this option then your machine
> never boots.  Well, it will boot.  Eventually.  Jack is a patient man,
> and he said he never waited long enough for it to boot.

Actually, I determined that a big system would never boot. Each cpu
would have to
do about 1500usec of work every 1000usec.  (highly dependent on the
system interconnect).

Each clock tick, the desc->irq_count is incremented by each cpu. On a
big
system, this creates an incredibly hot cache line. On a big system, it
takes
more than a millisecond to do the update. At that point, another clock
interrupt is already pending. Forward progress stops.

Another possible approach might be to special case note_interrupt() to
skip the update for the timer tick. (I havent actually looked at the
code, but
this should be possible). 


> 
> mh
> 
> -- 
> Martin Hicks || mort@bork.org || PGP/GnuPG: 0x4C7F2BEE

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
