From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 27 Apr 2004 00:31:32 +0000
Subject: Re: [patch] 2.6.5 BUG if smp_call_function is called with interrupts disabled
Message-Id: <16525.43492.463253.125638@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <9348.1083024579@ocs3.ocs.com.au>
In-Reply-To: <9348.1083024579@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 27 Apr 2004 10:09:39 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> + __asm__ __volatile__ ("mov %0=psr;; " : "=r" (psr))

Please no inline-asm.  Especially when there is a perfectly suitable
macro already (local_save_flags).

	--david
