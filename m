From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 20 Jun 2003 21:06:50 +0000
Subject: Re: 2.5.72 for ia64 released
Message-Id: <marc-linux-ia64-105614329229537@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105605890319553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105605890319553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


  Jesse> Oops, maybe I didn't Cc: you.  Here it is again, ...

OK, it _was_ my fault after all: I applied it in the to-linus-2.5 tree
but then forgot to pull it into the linux-ia64-2.5 tree before making
the new patch.  Sorry about that.

I just pushed out the latest linux-ia64-2.5 stuff, so if you could
verify that it's all there, that would be great (won't help with the
current 2.5.72 patch, but the next one should be OK).

	--david
