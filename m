From: Grant Grundler <iod00d@hp.com>
Date: Thu, 05 Feb 2004 21:50:09 +0000
Subject: Re: q-tools-0.0 released
Message-Id: <20040205215009.GA2316@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Dec 06, 2003 at 05:17:20PM -0800, David Mosberger wrote:
> I finally got around to releasing a _snaphot_ of my profiling tools.
...

> You can get q-tools from:
> 
>  ftp://ftp.hpl.hp.com/pub/linux-ia64/q-tools-0.0.tar.gz

Is there a newer version of the tools?
I tried to build this on a Debian "testing" box and got:
gsyprf3:/usr/src/q-tools-0.0# make
make[1]: Entering directory `/usr/src/q-tools-0.0/q-syscollect'
cc -g -O2 -Wall -D_GNU_SOURCE -I.  -c -o q-syscollect.o q-syscollect.c
q-syscollect.c:34:29: perfmon/perfmon.h: No such file or directory
q-syscollect.c:35:42: perfmon/perfmon_default_smpl.h: No such file or directory
q-syscollect.c:36:28: perfmon/pfmlib.h: No such file or directory
q-syscollect.c:37:37: perfmon/pfmlib_itanium2.h: No such file or directory
q-syscollect.c:131: error: parse error before "pd"
...


> There is a README in there which should contain everything needed to
> get you started (if not, complain and I'll fix it).

Ok! :^)

thanks,
grant

ps. looks very cool and I have a need for it.
