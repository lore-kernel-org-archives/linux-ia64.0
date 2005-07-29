From: Matt Chapman <matthewc@hp.com>
Date: Fri, 29 Jul 2005 22:10:44 +0000
Subject: __copy_user exception handling
Message-Id: <20050729221044.GA23144@kirby.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The main __copy_user loop looks like this:

2:
        EX(.failure_in3,(p16) ld8 val1[0]=[src1],16)
(p16)   ld8 val2[0]=[src2],16

        EX(.failure_out, (EPI)  st8 [dst1]=val1[PIPE_DEPTH-1],16)
(EPI)   st8 [dst2]=val2[PIPE_DEPTH-1],16
        br.ctop.dptk 2b

What I'm trying to understand is why there is no EX necessary on the
second store.  As far as I understand the implementation, src is 16-byte
aligned here, so there is no need for EX on the second load, since it
necessarily hits the same page.  But dst is only 8-byte aligned, so I
would think that the second store could fault.

I've done some testing and for some reason it doesn't seem to be a
problem in Linux; I haven't been able to produce an oops.  But I've hit
oopses in Xen (we use the same code), and so I'm trying to understand
*why* it's not a problem in Linux.

Does anyone have some insight?

Matt

