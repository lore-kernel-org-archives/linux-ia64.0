From: John Marvin <jsm@udlkern.fc.hp.com>
Date: Mon, 15 Mar 2004 12:40:07 +0000
Subject: Re: [PATCH]  Revised fix for show_mem panic
Message-Id: <200403151240.i2FCe7M19805@udlkern.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Oops. Usually I forget to include the patch. This time I sent the patch
without the intro text:

> Would it make sense to do only the first __get_user() _unless_ the
> "struct page" crosses a page?

Most likely. Although code that calls ia64_pfn_valid is going to be
dereferencing the page structure anyway, a page structure will always
cross a 1st level cache line, and will often cross a second level
cache line. The code may or may not touch both parts of the the
structure, so the test may prevent an unecessary cache line load,
and it won't take that many cycles to test for the case.

John
