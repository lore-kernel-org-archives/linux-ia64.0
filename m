From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 09 Apr 2003 17:33:59 +0000
Subject: Re: [Linux-ia64] mmap crashes system after mapping PCI device into user space and reading and writin
Message-Id: <marc-linux-ia64-105590723705448@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705441@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 8 Apr 2003 17:59:56 -0400, "Mike Fox" <mfox@annapmicro.com> said:

  Mike> Hi, I am running kernel version 2.4.19 and I am getting a
  Mike> system crash when I mmap my PCI device into user space and
  Mike> access it.

One thing you need to be careful about is memory attribute aliasing.
The CPU (or platform chips) can MCA if you try to access the same
physical location with different memory attributes (e.g., cached vs.
uncached).  Also, keep in mind that the kernel uses a 64MB page size
for the identity-mapped regions (regions 6 and 7).  This means that
you cannot map stuff requiring different attributes within the same
64MB page.  I kind of doubt this is what's causing the problem for
you, but since you didn't give any details about the hw you're trying
to map, it's hard to be more specific.

As others have pointed out, it's of course also important to verify
that you access I/O space uncached.

	--david

