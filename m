From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 22 Apr 2002 23:07:33 +0000
Subject: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905495@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 22 Apr 2002 15:39:46 -0700, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> Except that pci_alloc_consistent is supposed to return a 32
  Jesse> bit address...

Oh man, what a mess!  Have you checked with Dave Miller?  I suspect
he might not like this.  I'm not terribly fond of it either as it
makes it even more confusing as to when to use the DAC interface.  I'd
rather see a separate "alloc_consistent" routine, which doesn't isn't
on <4GB addresses.

	--david

