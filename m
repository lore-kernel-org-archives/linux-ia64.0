From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 26 Jul 2004 23:42:54 +0000
Subject: Re: [BROKEN PATCH] kexec for ia64
Message-Id: <16645.38654.649250.630791@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407261524.40804.jbarnes@engr.sgi.com>
In-Reply-To: <200407261524.40804.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 26 Jul 2004 16:34:01 -0700, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> On Monday, July 26, 2004 4:30 pm, David Mosberger wrote:
  >> >>>>> On Mon, 26 Jul 2004 16:09:51 -0700, David Mosberger >>>>>
  >> <davidm@linux.hpl.hp.com> said:

  >> Oops, the first sentence got garabled: it was meant to say:

  Jesse> So we just need to avoid EFI boot time services in the kexec
  Jesse> path, ok.  How about the kernel relocation question?

No idea.  I haven't looked at the ia64 kexec patch or relocate_kernel.S.
I don't see any reason why your suggestion shouldn't work, but with
these kinds of things, the devil is always in the detail.

	--david
