From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Jan 2005 21:50:08 +0000
Subject: Re: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <16888.4240.245250.132321@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 26 Jan 2005 15:40:47 -0600 (CST), Russ Anderson <rja@sgi.com> said:

  Russ> There is one small problem.  In mca_asm.S, r23 was used
  Russ> without being set and the hardcoded value 40 is no longer
  Russ> valid (patch below).

Ah, I missed that.

  Russ> With linux-ia64-test-2.6.11 plus David's patch plus the patch
  Russ> below, 1024 memory uncorectable errors were injected and
  Russ> sucessfully recovered on an SGI Altix test machine.  1024 is
  Russ> the number of entries in the page_isolate[] array in
  Russ> arch/ia64/kernel/mca_drv.c.  When the array is full, the
  Russ> recovery code says the error is not recoverable and the system
  Russ> reboots.

Cool!

Tony, will you take the patches?  (Yes, there is still a question of
how to cleanup/unify the MCA state allocation, but I think that's best
done separately.)

	--david
