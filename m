From: Christoph Hellwig <hch@ns.caldera.de>
Date: Tue, 11 Sep 2001 10:26:31 +0000
Subject: Re: [Linux-ia64] Location of absolute IA32 shared objects.
Message-Id: <marc-linux-ia64-105590698805171@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805122@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805122@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Sep 10, 2001 at 09:30:02PM -0700, Ulrich Drepper wrote:
> David Mosberger <davidm@hpl.hp.com> writes:
> 
> > As far as I can see, neither LSB nor FHS address the issue of where
> > to place emulation files, so I'll propose a prefix of
> > "/emul/ia32-linux/" as a starter.  Any objections?
> 
> Not that I care, but this is clearly a place for a new /proc entry
> which can be changed by the sysadmin.

If that is the general consensus I will globally move the emul prefix
stuff to /proc based values instead of compile-time defines.

Any objections?

	Christoph

-- 
Of course it doesn't work. We've performed a software upgrade.

