From: Grant Grundler <iod00d@hp.com>
Date: Fri, 02 Sep 2005 22:23:52 +0000
Subject: Re: [PATCH 2.6.13] IOCHK interface for I/O error handling/detecting (for ia64)
Message-Id: <20050902222352.GB12105@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <431694DB.90400@jp.fujitsu.com> <20050901172917.I10072@chenjesu.americas.sgi.com> <20050902164828.GA10587@esmail.cup.hp.com> <ed5aea430509021116233eeb39@mail.gmail.com>
In-Reply-To: <ed5aea430509021116233eeb39@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David.Mosberger@acm.org
Cc: Grant Grundler <iod00d@hp.com>, Brent Casavant <bcasavan@sgi.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, linux-ia64@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>

On Fri, Sep 02, 2005 at 11:16:10AM -0700, david mosberger wrote:
> > Sorry - I think this is BS.
> > 
> > Please run mmio_test on your box and share the results.
> > mmio_test is available here:
> >         svn co http://svn.gnumonks.org/trunk/mmio_test/
> 
> Reads are slow, sure, but writes are not (or should not).

Sure, MMIO writes are generally posted. But those aren't always "free".
At some point, I expect MMIO reads typically will flush those writes
and thus stall until 2 (or more) PCI bus transactions complete.

ISTR locking around MMIO writes was necessary if the box
to enforce syncronization of the error with the driver.
ISTR this syncronization was neccessary.  Was that wrong?

Complicating the MMIO perf picture are fabrics connecting the NUMA cells
which do NOT enforce MMIO ordering (e.g. Altix).
In that case, arch code will sometimes need to enforce the write ordering
by flushing MMIO writes before a driver releases a spinlock or other
syncronization primitive. This was discussed before and is archived in
the dialog between Jesse Barns and myself in late 2004 (IIRC).

In any case, mmio_test currently only tests MMIO read perf.
I need to think about how we might also test MMIO write perf.
Ie how much more expensive is MMIO read when it follows an MMIO write.


grant
