From: Al Stone <ahs3@fc.hp.com>
Date: Fri, 06 Feb 2004 17:54:45 +0000
Subject: Re: q-tools-0.0 released
Message-Id: <1076090084.886.24.camel@fcboson.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040205215009.GA2316@cup.hp.com>
In-Reply-To: <20040205215009.GA2316@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2004-02-06 at 05:24, Matthew Wilcox wrote:
> On Thu, Feb 05, 2004 at 11:26:47PM -0800, Stephane Eranian wrote:
> > Grant,
> > 
> > On Thu, Feb 05, 2004 at 09:05:21PM -0800, Grant Grundler wrote:
> > > On Thu, Feb 05, 2004 at 02:57:22PM -0800, Stephane Eranian wrote:
> > > > You need to have libpfm-3.0 installed on your system.
> > > > I think Al Stone published the package on the Debian sites.
> > > > You need the development + runtime packages.
> > > 
> > > Stephane,
> > > Yes, he did.
> > > Debian currently has:
> > > ii  libpfm         2.0-6          IA-64 Performance Monitor (PMU) -- runt-time
> > > ii  libpfm-dev     2.0-6          IA-64 Performance Monitor (PMU) -- developme
> > > ii  pfmon          3.0-2          a performance monitoring tool for Linux/ia64
> > > 
> > > The pfmon from debian was probably built against "2.0-6" libpfm.
> > That's wrong. I don't event think it compiles that way.

No, that is not correct.  The pfmon_3.0-1 packages includes
_both_ the 2.0 and 3.0 pfmon commands plus a wrapper that
determines what kernel is currently being run and execs the
proper pfmon.  Each of the pfmon commands was built using 
the proper version of libpfm.

The pfmon_3.0-1 packages depends on libpfm2_2.0-1 and
libpfm3_3.0-1 (but not the -dev packages).

> > > Is that bad?
> > Yes, it is. there should be a libpfm_3.0 and libpfm-dev_3.0 packages.

There are:
   -- libpfm2 and libpfm2-dev packages.
   -- libpfm3 and libpfm3-dev packages.

Note that I chose to move the location of the header files
in the -dev packages so they wouldn't overwrite one another
(they used to both go in /usr/include/perfmon, but now go in
/usr/include/perfmon2 and /usr/include/perfmon3); the other
alternative was to completely rewrite them and merge them so
they had the proper API for the proper kernel version.  I may
yet do that, but it seemed more important to get the 3.0 stuff
out first.

> Looks like the Debian packages have some problems:
> 
> Package: pfmon
> Depends: libc6.1 (>= 2.3.2.ds1-4), libelfg0, libpfm2, libpfm3
> $ sudo apt-get install pfmon
> The following packages have unmet dependencies:
>   pfmon: Depends: libpfm2 but it is not installable
>          Depends: libpfm3 but it is not installable
> 
> Al, what's up?

Hmmm.  I must have missed a case in my install testing.
pfmon is set up to depend on libpfm2 and libpfm3.  libpfm2
was told to replace libpfm.  It looks like I forgot to tell
it to replace libpfm-dev, too.  Oops.  I'll rebuild and
upload later today.  If you remove libpfm and libpfm-dev
in the meantime, the install should proceed.  Sorry 'bout
that....

-- 
Ciao,
al
----------------------------
Al Stone
Linux & Open Source Lab
Hewlett-Packard Company
E-mail: ahs3@fc.hp.com
----------------------------

