From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 01 Aug 2002 18:17:00 +0000
Subject: Re: [Linux-ia64] 64K pages on Itanium 1
Message-Id: <marc-linux-ia64-105590701905879@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905876@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905876@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 02 Aug 2002 01:00:42 +1000, Keith Owens <kaos@ocs.com.au> said:

  Keith> A recent 2.4.18 ia64 patch removed 64K page support for
  Keith> Itanium 1, only allowing it for McKinley.  What is the
  Keith> restriction on Itanium 1?  I have a test case that needs 64K
  Keith> pages and I was hoping to run it on Big Sur.  The simple test
  Keith> of allowing 64K for Itanium 1 breaks as soon as it enters
  Keith> user space, during binfmt_elf processing.

The problem is that Itanium 1 has few enough virtual address bits that
with 64KB pages, you end up with an overlap between the user address
space and the virtually mapped linear page table.  This can be worked
around (there was a patch from someone at SGI, at some point), but it
wasn't very clean and I didn't think it's worth bothering with it
introduced, given that Itanium 2 solves the problem automagically
(since it supports the full 64 bits of virtual address space).

	--david

