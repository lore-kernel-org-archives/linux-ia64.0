From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 26 Jul 2004 23:09:51 +0000
Subject: Re: [BROKEN PATCH] kexec for ia64
Message-Id: <16645.36671.580858.707082@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407261524.40804.jbarnes@engr.sgi.com>
In-Reply-To: <200407261524.40804.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 26 Jul 2004 15:24:40 -0700, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> I'm also worried about a few things in this patch.  Is
  Jesse> relocate_kernel.S really necessary in 2.6?  Can we copy the
  Jesse> kernel to a contiguous 64MB aligned area, drop into phys mode
  Jesse> and just jump to it?  Also, what about EFI boot services and
  Jesse> PROM tables that the kernel frees part way through boot?
  Jesse> Should we copy those into a safe place for the new image at
  Jesse> boot time?  Or just leave them there if CONFIG_KEXEC is
  Jesse> enabled?

I suspect option one is really feasible.  The first one probably just
doesn't work and the second one could waste relatively large amounts
of memory.  Perhaps the third option of not using EFI boot-time
services at all during kexec should be considered.

	--david
