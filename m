From: Christoph Hellwig <hch@ns.caldera.de>
Date: Tue, 18 Sep 2001 20:25:01 +0000
Subject: Re: [Linux-ia64] Re: PROPOSED: 32/64 bit coexistance
Message-Id: <marc-linux-ia64-105590698805217@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805199@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805199@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 18, 2001 at 10:07:53PM +0200, Andreas Jaeger wrote:
> David Mosberger <davidm@hpl.hp.com> writes:
> 
> >>>>>> On Tue, 18 Sep 2001 19:50:52 +0200, Andreas Jaeger <aj@suse.de> said:
> >
> >   >> It turns out that three of the four resulting possibilities make
> >   >> sense:
> >   >> 
> >   >> (1) ia64/ilp32 (2) ia64/lp64 (3) x86/ilp32
> >
> >   Andreas> Then we should discuss where those will end.  For ia64, the
> >   Andreas> places are according to the proposal:
> >
> >   Andreas> (1) not defined
> >   Andreas> (2) /lib and /usr/lib
> >   Andreas> (3) not defind - but not /lib
> >
> > (2) is fine, but I think LSB should also (3)---at least for ia64.
> > It's important for distributors to agree on the local of (3).  The
> > current proposal is /emul/ia32-linux.
> 
> I agree and will add it to the proposal.

Would you mind adding my extended version, i.e.

	/emul/[<arch>-]<opsys>

for non-native trees?

	Christoph

-- 
Of course it doesn't work. We've performed a software upgrade.

