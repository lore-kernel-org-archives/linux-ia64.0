From: Luigi Genoni <venom@DarkStar.sns.it>
Date: Tue, 18 Sep 2001 09:21:57 +0000
Subject: [Linux-ia64] Re: PROPOSED: 32/64 bit coexistance
Message-Id: <marc-linux-ia64-105590698805208@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805199@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805199@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 18 Sep 2001, Theodore Tso wrote:

> Date: Tue, 18 Sep 2001 05:00:50 -0400
> From: Theodore Tso <tytso@mit.edu>
> To: Andreas Jaeger <aj@suse.de>
> Cc: fhs-discuss@ucsd.edu, linux-ia64@linuxia64.org,
>      lsb-spec@lists.linuxbase.org, Brad_Brech/Rochester/IBM@de.ibm.com,
>      jporell@us.ibm.com, Michael_Day/Austin/IBM@de.ibm.com,
>      Ron_Clark/Austin/IBM@de.ibm.com, George_Kraft/Austin/IBM@de.ibm.com,
>      Paul_McKenney/Beaverton/IBM@de.ibm.com,
>      Kenneth_Rozendal/Austin/IBM@de.ibm.com,
>      Satya_Sharma/Austin/IBM@de.ibm.com, ADLUNG@de.ibm.com, dbb@caldera.com,
>      mkraft@suse.de, David Mosberger <davidm@hpl.hp.com>
> Subject: Re: PROPOSED: 32/64 bit coexistance
> Resent-Date: Tue, 18 Sep 2001 11:02:12 +0200
> Resent-From: lsb-spec@lists.linuxbase.org
>
> On Tue, Sep 18, 2001 at 10:34:50AM +0200, Andreas Jaeger wrote:
> >
> >    * /lib: consistent scheme for all 32bit systems and x86-64,
> >      sparc64, ppc64, zSeries (s390x).
> >
> >    * iA64 today has a 32bit emulation mode, but 64bit is the
> >      (only) favored one; Alpha is too long established. (64bit
> >      libs will go to /lib)
> >
>
> Does Sparc/Ultrasparc use /lib and /lib64?  Or will this be a change
> for the Ultrasparc platform?
Actually userspace for ultrasparc is only 32 bits, there is a 64 bit
compiler for the kernel, I think, but I've never seeen 64 bits libraries
except the ones inside of /usr/lib/gcc-lib/<sprac>/<egcs-xxx>.

Luigi



