From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 21 May 2003 06:49:17 +0000
Subject: [Linux-ia64] web page on O(1) scheduler
Message-Id: <marc-linux-ia64-105590723705965@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Recently, I started to look into some odd performance behaviors of the
O(1) scheduler.  I decided to document what I found in a web page
at:

	http://www.hpl.hp.com/research/linux/kernel/o1.php

(it may take another couple of hours before the pages show up outside
the HP firewall, so if you get "page not found" at the moment, don't
be surprised).

I should say that I have no direct stake in the CPU scheduler (never
worked on it, not sure I ever would want to), but I feel that it's
worthwhile to at least document the O(1) scheduler a bit better.
Also, I do feel that the O(1) scheduler currently has rather poor
"long-term" properties.  It would be nice if some of those properties
could be improved without hurting the other excellent properties of
the current O(1) scheduler.

I think the web pages should be most relevant to the HPTC (high
performance technical computing) community, since this is the
community that is most likely affected by some of the performance
oddities of the O(1) scheduler.  Certainly anyone using OpenMP on
Intel platforms (x86 and ia64) may want to take a look.

Comments welcome.

	--david

