From: david mosberger <dmosberger@gmail.com>
Date: Fri, 02 Sep 2005 18:16:10 +0000
Subject: Re: [PATCH 2.6.13] IOCHK interface for I/O error handling/detecting (for ia64)
Message-Id: <ed5aea430509021116233eeb39@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <431694DB.90400@jp.fujitsu.com>
	 <20050901172917.I10072@chenjesu.americas.sgi.com>
	 <20050902164828.GA10587@esmail.cup.hp.com>
In-Reply-To: <20050902164828.GA10587@esmail.cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: Brent Casavant <bcasavan@sgi.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, linux-ia64@vger.kernel.org, Linux Kernel list <linux-kernel@vger.kernel.org>

On 9/2/05, Grant Grundler <iod00d@hp.com> wrote:
> On Thu, Sep 01, 2005 at 05:45:54PM -0500, Brent Casavant wrote:
> ...
> > The first is serialization of all I/O reads and writes.  This will
> > be a severe problem on systems with large numbers of PCI buses, the
> > very type of system that stands the most to gain in reliability from
> > these efforts.  At a minimum any locking should be done on a per-bus
> > basis.
> 
> The lock could be per "error domain" - that would require some
> arch specific support though to define the scope of the "error domain".

I do not think the basic inX/outX and readX/writeX operations should
involve spinlocks.  That would be really nasty if an MCA/INIT handler
had to call them, for example...

> > The second is the raw performance penalty from acquiring and dropping
> > a lock with every read and write.  This will be a substantial amount
> > of activity for any I/O-intensive system, heck even for moderate I/O
> > levels.
> 
> Sorry - I think this is BS.
> 
> Please run mmio_test on your box and share the results.
> mmio_test is available here:
>         svn co http://svn.gnumonks.org/trunk/mmio_test/

Reads are slow, sure, but writes are not (or should not).

  --david
-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
