From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 11 Oct 2001 15:39:10 +0000
Subject: [Linux-ia64] warning: avoid 2.4.11
Message-Id: <marc-linux-ia64-105590698805335@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2.4.11 has a nasty symlink-related bug.  See Linus's message for
details:

 http://linuxtoday.com/news_story.php3?ltsn 01-10-11-007-20-NW-KN

I assume the 2.4.12 applies cleanly on top of the ia64 patch, but in
any case, I am planning to release a matching ia64 patch asap
(hopefully tonight).

	--david

