From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 22 Jan 2002 19:02:27 +0000
Subject: Re: [Linux-ia64] native ia64 32-bits compile & run on linux-ia64?
Message-Id: <marc-linux-ia64-105590698805914@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805893@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805893@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I think one point that hasn't been made so far is that we actively
discourage supporting an ILP32 data model for IA-64 Linux to avoid
splitting ia64 linux into two different worlds (32-bit and 64-bit
world).  If we supported ILP32, it's very likely that some ISVs will
decide to provide *only* 32-bit libraries, which could in turn force
other ISVs to stay with 32-bit just because they couldn't get the
pre-requisite 64-bit libraries.  My understanding is that IRIX
suffered from this effect.

There are times where an ILP32 model would achieve slightly better
performance, but it's certainly not always the case and, in my
opinion, the potential performance benefit is not worth the cost of
having to maintain two data models (ILP32 and LP64).  Note that the
cost is not just in developing, testing, and maintaining two versions
of each library, but also in added complexity for programmers.

	--david

