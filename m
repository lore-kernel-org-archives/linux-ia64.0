From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 10 Sep 2001 15:49:19 +0000
Subject: Re: [Linux-ia64] Re: Write Combining (Write Coalescing) on memory mapped
Message-Id: <marc-linux-ia64-105590698805155@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805106@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805106@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 10 Sep 2001 17:26:47 +0200, Steffen Persvold <sp@scali.no> said:

  Steffen> This is what my original post (which included a patch)
  Steffen> tried to do, but I didn't get it too work. I know you gave
  Steffen> me feedback on this David, saying that it just may need
  Steffen> some debugging. Does anyone on the list have the time to
  Steffen> just look through the patch and try to analyze what's going
  Steffen> wrong (or maybe just give me some hints on what to look
  Steffen> for) ?

I don't, not in the near future at least.

There is nothing magical about debugging on ia64.  Just use the normal
techniques: try to narrow down what's triggering the problem, e.g.,
via binary search, printk, etc.  A kdb patch is also available.

	--david

