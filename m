From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 03 May 2004 22:28:18 +0000
Subject: Re: 2.6.5 unwind problem with rp <- r0
Message-Id: <16534.51074.123860.511966@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4885.1083211711@kao2.melbourne.sgi.com>
In-Reply-To: <4885.1083211711@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 29 Apr 2004 14:08:31 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> Unwinding through a kernel thread, we hit
  Keith> kernel_thread_helper which is called from start_kernel_thread
  Keith> with unwind data

  Keith>         .save rp, r0 // this is the end of the call-chain

  Keith> The kernel unwinder does not handle this correctly, it spits
  Keith> unwind.pt_regs_off: bad scratch reg r0 and keeps unwinding,
  Keith> generating garbage.

For now, I think the best solution is to avoid the idiom.  I don't
want to make too many changes to the existing kernel unwinder anymore.
That is, I'd rather spend time on a libunwind-based kernel unwinder.

	--david
