From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 10 May 2001 14:26:38 +0000
Subject: Re: [Linux-ia64] Replacements for local_irq_xxx()
Message-Id: <marc-linux-ia64-105590693005563@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005562@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005562@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 10 May 2001 18:55:13 +1000, Keith Owens <kaos@ocs.com.au> said:

  Keith> Existing local_irq_xxx() routines clear psr.i which masks all
  Keith> interrupts, including NMI.  Then the only way to get the
  Keith> attention of a cpu in a disabled spin loop is via INIT which
  Keith> is too drastic.  How about these alternatives which set
  Keith> cr.tpr.mmi instead, masking all external interrupts except
  Keith> NMI?

I'd rather not do that.  Accessing tpr is slow and requires explicit
serialization.

	--david

