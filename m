From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 17 Oct 2003 17:31:27 +0000
Subject: Re: [patch] xbow.c kmalloc fixes
Message-Id: <marc-linux-ia64-106641220628729@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

So what should be done about these SN2 cleanups?  I don't want to
accept dozens of small "fixes" (which really are mostly cleanups) as
that would defeat the idea of the code-fixes-only decree.  On the
other hand, I really would like to see the SN2 code cleaned up so we actually
have a sane base to do bug fixes on top of.

Perhaps it would actually be a better idea to have one big SN2 cleanup
patch which gets applied directly by Andrew?  It seems like he would
be OK with a one-time exception (since the code had been in the works
and since the old code is so gross) and as long as the patch doesn't
break GENERIC compiles, I'm going to be OK with it anyhow.  How about
it?

	--david
