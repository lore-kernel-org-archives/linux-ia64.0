From: Mark Goodwin <markgw@sgi.com>
Date: Tue, 11 Sep 2001 11:25:39 +0000
Subject: Re: [Linux-ia64] Location of absolute IA32 shared objects.
Message-Id: <marc-linux-ia64-105590698805172@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805122@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805122@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 11 Sep 2001, Christoph Hellwig wrote:

> On Mon, Sep 10, 2001 at 09:30:02PM -0700, Ulrich Drepper wrote:
> > David Mosberger <davidm@hpl.hp.com> writes:
> > 
> > > As far as I can see, neither LSB nor FHS address the issue of where
> > > to place emulation files, so I'll propose a prefix of
> > > "/emul/ia32-linux/" as a starter.  Any objections?
> > 
> > Not that I care, but this is clearly a place for a new /proc entry
> > which can be changed by the sysadmin.
> 
> If that is the general consensus I will globally move the emul prefix
> stuff to /proc based values instead of compile-time defines.
> 
> Any objections?

RPM installs for ia32 apps/libs will need to use --prefix `cat /proc/ia32prefix`
or whatever. If sysadmin subsequently changes the prefix, it wont work. Would a
better solution be an ia32 specifc version of /etc/ld.so.conf? Or perhaps the
/proc file should allow multiple search paths?

-- Mark


