From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 24 Mar 2003 21:54:56 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20 ia64_sal_mc_rendez must not lock
Message-Id: <marc-linux-ia64-105590723705306@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705290@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705290@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I made the analogous change in 2.5 (patch didn't apply due to some
other changes).  Also, I changed the local variable names in the
macros to avoid name collisions.

	--david

>>>>> On Sat, 22 Mar 2003 15:51:54 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> No cpu will return from ia64_sal_mc_rendez() until all cpus have
  Keith> entered rendezvous and the monarch cpu sends the wake up ipi.  All cpus
  Keith> try to call ia64_sal_mc_rendez() but only the first one makes it, the
  Keith> others all block on the spinlock and eventually SAL hits them with an
  Keith> INIT.

  Keith> Why do I get the feeling that I am the first person to really use this
  Keith> code?

  Keith> With this patch and my previous patch to set
  Keith> SAL_MC_PARAM_RZ_ALWAYS, kdb v4.0 gets backtrace on _ALL_ cpus
  Keith> when an MCA occurs.  Well, almost all, if any of the cpus are
  Keith> spinning disabled then the MCA rendezvous interrupt does not
  Keith> get through, SAL sends INIT and that cpu drops into INIT
  Keith> processing.  kdb processing for INIT handlers is not complete
  Keith> yet, work in progress.


