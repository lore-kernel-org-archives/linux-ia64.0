From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 05 Jan 2001 19:05:06 +0000
Subject: Re: [Linux-ia64] Does 2.4.0 (final) not compile out of the box?
Message-Id: <marc-linux-ia64-105590678205888@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205879@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205879@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 5 Jan 2001 16:16:40 +0100, Dambacher <ulf.dambacher@mach.uni-karlsruhe.de> said:

  Dambacher> Hi at linux-ia64 I just got the latest "final" version of
  Dambacher> 2.4.0 wich ist out since yesterday, it is said to compile
  Dambacher> on ia64 out of the box, but what then did I get wrong?

No, it doesn't compile out of the box.  The stuff in 2.4.0 is very
close to the IA-64 tree, but you still need IA-64 specific patches
that didn't make it into the 2.4.0 tree.  An updated patch should be
out sometime soon (Monday, hopefully).

	--david

