From: Grant Grundler <iod00d@hp.com>
Date: Thu, 05 Feb 2004 22:28:24 +0000
Subject: Re: q-tools-0.0 released
Message-Id: <20040205222824.GA2508@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040205215009.GA2316@cup.hp.com>
In-Reply-To: <20040205215009.GA2316@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 05, 2004 at 01:50:09PM -0800, Grant Grundler wrote:
> > You can get q-tools from:
> > 
> >  ftp://ftp.hpl.hp.com/pub/linux-ia64/q-tools-0.0.tar.gz
> 
> Is there a newer version of the tools?
> I tried to build this on a Debian "testing" box and got:
> gsyprf3:/usr/src/q-tools-0.0# make
> make[1]: Entering directory `/usr/src/q-tools-0.0/q-syscollect'
> cc -g -O2 -Wall -D_GNU_SOURCE -I.  -c -o q-syscollect.o q-syscollect.c
> q-syscollect.c:34:29: perfmon/perfmon.h: No such file or directory
> q-syscollect.c:35:42: perfmon/perfmon_default_smpl.h: No such file or directory
> q-syscollect.c:36:28: perfmon/pfmlib.h: No such file or directory
> q-syscollect.c:37:37: perfmon/pfmlib_itanium2.h: No such file or directory
> q-syscollect.c:131: error: parse error before "pd"
> ...

Ok - part of this was resolved by grabbing pfmon-devel-1.1-1.ia64.rpm
from the same FTP location.

Still not finding one of the header files...
gsyprf3:/usr/src/q-tools-0.0# make
make[1]: Entering directory `/usr/src/q-tools-0.0/q-syscollect'
cc -g -O2 -Wall -D_GNU_SOURCE -I.  -c -o q-syscollect.o q-syscollect.c
q-syscollect.c:35:42: perfmon/perfmon_default_smpl.h: No such file or
directory
q-syscollect.c:131: error: `PFMLIB_MAX_PMDS' undeclared here (not in a
function)
q-syscollect.c:137: error: parse error before '*' token
...

Stephane,
Maybe I need newer pfmon "devel" package?

thanks,
grant
