From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 15 Jan 2005 06:04:37 +0000
Subject: time to reconsider HZ?
Message-Id: <16872.45685.696721.811934@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Since most other Linux platforms which use HZ>100 use a HZ value of
1000, I'm thinking it may be safer to switch ia64 to HZ00 as well
(principle of least difference possible is generally a good one...).

In the past, I was concerned that there might be enough code that
divides by HZ that this might not be such a hot idea, but I think this
may not (or at least no longer) be the case: I compiled the same
kernel once with HZ00 and once with HZ24 and the code-size
actually shrunk.

What do others think?

	--david
