From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 25 Mar 2004 22:28:02 +0000
Subject: Re: should ia64_spinlock_contention do backoff?
Message-Id: <16483.23794.749679.238180@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403251941.i2PJfrTH026392@napali.hpl.hp.com>
In-Reply-To: <200403251941.i2PJfrTH026392@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 26 Mar 2004 09:13:14 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> [*] Extract of patched 2.4 out of line contention code.  The
  Keith> exponential backoff code came from early 2.4 kernels.

Yeah, I thought it looked similar to something I wrote a long time
ago! ;-)

Thanks for sharing the info.  I agree that it's difficult to find the
ideal trade-off between low-latency in the lightly contended case and
low bus utilization in the highly contended case.

Until someone finds data to the contrary, I'll assume that exponential
backoff isn't worth the trouble for the kernel (user-level is a very
different story, of course).

Thanks,

	--david
