From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 05 Feb 2004 22:57:22 +0000
Subject: Re: q-tools-0.0 released
Message-Id: <20040205225722.GB5918@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040205215009.GA2316@cup.hp.com>
In-Reply-To: <20040205215009.GA2316@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Grant,

On Thu, Feb 05, 2004 at 02:28:24PM -0800, Grant Grundler wrote:
> On Thu, Feb 05, 2004 at 01:50:09PM -0800, Grant Grundler wrote:
> > > You can get q-tools from:
> > > 
> > >  ftp://ftp.hpl.hp.com/pub/linux-ia64/q-tools-0.0.tar.gz
> > 
> > Is there a newer version of the tools?
> > I tried to build this on a Debian "testing" box and got:
> > gsyprf3:/usr/src/q-tools-0.0# make
> > make[1]: Entering directory `/usr/src/q-tools-0.0/q-syscollect'
> > cc -g -O2 -Wall -D_GNU_SOURCE -I.  -c -o q-syscollect.o q-syscollect.c
> > q-syscollect.c:34:29: perfmon/perfmon.h: No such file or directory
> > q-syscollect.c:35:42: perfmon/perfmon_default_smpl.h: No such file or directory
> > q-syscollect.c:36:28: perfmon/pfmlib.h: No such file or directory
> > q-syscollect.c:37:37: perfmon/pfmlib_itanium2.h: No such file or directory
> > q-syscollect.c:131: error: parse error before "pd"
> > ...
> 
You need to have libpfm-3.0 installed on your system. I think 
Al Stone published the package on the Debian sites. You need the
development + runtime packages.

If you don't find the Debian package, then download:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/libpfm-3.0.tar.gz

Note that q-tools/libpfm-3.0/pfmon-3.0 ONLY work on 2.6 kernels.

-- 

-Stephane
