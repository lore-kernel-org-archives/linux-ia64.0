From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 10 Sep 2001 14:51:03 +0000
Subject: Re: [Linux-ia64] Re: Write Combining (Write Coalescing) on memory mapped
Message-Id: <marc-linux-ia64-105590698805152@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805106@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805106@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 10 Sep 2001 16:16:31 +0200, Steffen Persvold <sp@scali.no> said:

  Steffen> Steffen Persvold wrote:

  >> Do you think it's easier to set up a region which is mapped all
  >> the time, so that ioremap_nocache() uses the already defined
  >> region 6 for uncached accesses and ioremap() uses this new region
  >> with "Write Coalescing" enabled ? How should I proceed to
  >> introduce such a region ?

  Steffen> I haven't received any response. Does that mean that you
  Steffen> guys don't even care about this issue ??

I thought I had answered this already: I don't think it's worthwhile
to use up another region for write combining mappings.  There are no
free regions at the moment at any rate.  It's quite possible that
we'll get rid of the uncached region at some point in the future as
well.

	--david

