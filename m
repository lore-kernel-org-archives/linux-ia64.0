From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 05 May 2004 23:38:25 +0000
Subject: Re: 2.6.5 unwind problem with rp <- r0
Message-Id: <16537.31473.86874.655825@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4885.1083211711@kao2.melbourne.sgi.com>
In-Reply-To: <4885.1083211711@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 05 May 2004 10:04:58 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> This ugly kludge handles unwinding from a value in r0.  It
  Keith> gets the kernel unwinder working again, until it can be
  Keith> replaced by libunwind.

I hate kludges.

An alternative that might make you happy: in kernel_thread(),
initialize regs.sw.r4 to 0, then change start_kernel_thread's
prologue to:

	.prologue
	.save rp, r4
	.body

Want to try this?

	--david
