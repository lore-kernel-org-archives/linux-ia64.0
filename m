From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 15 Mar 2003 06:46:28 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-ia64-021210 new spinlock code
Message-Id: <marc-linux-ia64-105590709806131@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805543@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805543@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I thought about it some more and recalled why I was so uneasy about
claiming ar.pfs is 0: the problem is that this informs that the
_previous_ register frame was empty, not the current one.  So the
unwind info technically is still wrong.  I think you realize that, and
the kernel unwinder won't complain, since it's not paranoid about
validating accesses to stacked registers.  But still, the unwind info
is wrong and I'm not terribly comfortable with that.

	--david

