From: Erich Focht <focht@ess.nec.de>
Date: Thu, 04 Apr 2002 19:27:58 +0000
Subject: Re: [Linux-ia64] SIGILL errors in strncpu (NAT consumption)
Message-Id: <marc-linux-ia64-105590701905380@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905358@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905358@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 3 Apr 2002, David Mosberger wrote:

> It's due to a glibc bug that was introduced last August when strncpy()
> was rewritten.  I sent a bug report (and preliminary patch) to the
> author and am waiting to hear back.

The error I've seen didn't have anything to do with strncpy(), the loop
where the strange SIGILL and "NaT consumption" came from was:

      DO 502 IB=1,NBCUT0
      if(IB.GT.NBNCST.AND.IB.LE.NBNCEN) GO TO 502
      IP1=LCU(1,IB)
      IP2=LCU(2,IB)
      IF(LQ(1,IP1).LT.-NBC.OR.LQ(1,IP2).LT.-NBC) GO TO 502
      IDP1=NDIR(ICU(1,IB))
      LQ(IDP1,IP1)=LCB(1,IB)
      IDP2=NDIR(ICU(2,IB))
      LQ(IDP2,IP2)=LCB(2,IB)
  502 CONTINUE

You shouldn't blame me for the first IF condition, it's a third party
(ISV) code. The assembler code produced by the Fortran compiler looked
correct.

What change did you make for strncpy()? Did it somehow produce a NaT
somewhere where it could influence a Fortran program? I'd like to
understand whether the problem comes from a strange combination of
instructions or somehow propagates from glibc. Splitting the loop and
eliminating the first IF helped in this case, so it's improbable that
strncpy() is related to this.

Thanks,
best regards,
Erich



