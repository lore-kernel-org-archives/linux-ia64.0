From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 27 Apr 2004 00:54:00 +0000
Subject: Re: [patch] 2.6.5 BUG if smp_call_function is called with interrupts disabled
Message-Id: <16525.44840.984014.400124@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <9348.1083024579@ocs3.ocs.com.au>
In-Reply-To: <9348.1083024579@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 27 Apr 2004 10:43:39 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> Sorry, ported from an older 2.4 kernel.  Redo.

Sorry for doing this in an incremental fashion, but upon re-reading
your patch, I vaguely remembered that we had a macro to check whether
irqs are disabled.  Sure enough, there is:

	irqs_disabled()

  --david
