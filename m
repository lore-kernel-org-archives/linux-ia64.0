From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 20 Feb 2004 23:09:18 +0000
Subject: Re: Oops in pdflush
Message-Id: <16438.37790.455816.252879@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 20 Feb 2004 18:11:36 +0100, Andreas Schwab <schwab@suse.de> said:

  Andreas> David Mosberger <davidm@napali.hpl.hp.com> writes:
  >>>>>>> On Fri, 20 Feb 2004 14:34:03 +0100, Andreas Schwab <schwab@suse.de> said:
  Andreas> This happens regularily on all our Intel Tiger SMP systems,
  Andreas> haven't seen it on UP systems, and neither on any HP system
  Andreas> we have.  Theses oopses are all from different systems
  Andreas> running kernels 2.6.2 and 2.6.3 in various incarnations.

  >> As an additional data-point: we have a tiger here, too, and it's
  >> running 2.6.2-rc2 just fine (it's a build-server so we try not to
  >> reboot it too often).  Are you saying that 2.6.1 was OK and you
  >> started to see the problems only with 2.6.2?

  Andreas> I can't tell when it started, but I think 2.6.1 already had similar
  Andreas> problems.

That's rather strange.  I'm sure the Intel folks test on Tiger all the
time and Andrew also seems to test on his Tiger quite frequently.
Is this with a particular workload?

In any case, it's not good that the stack-trace is truncated.
gcc-3.3.3 should be good enough, so I'm not sure off hand what's going
wrong.  If you could enable unwind-debugging (set UNW_DEBUG to 5 in
arch/ia64/kernel/unwind.c) and capture the resulting output during a
crash, it might get us further.

	--david
