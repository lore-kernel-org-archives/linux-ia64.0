From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 12 Apr 2001 23:38:41 +0000
Subject: [Linux-ia64] crashes with 2.4.3
Message-Id: <marc-linux-ia64-105590693005398@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just a heads up: some of you have noticed that the 2.4.3 kernel
occasionally panics due to a call to BUG() in the
read-/write-semaphore.  I saw this once about 5 minutes after booting
a kernel and then didn't see it again for another 5 days or so until
it happen today.  I looked into it and I concluded that it's pretty
much a "generic" problem that has existed with the
read-/write-semaphores since their inception.  The problem also shows
on x86 and Alan Modra is working on a generic solution to the problem.
Since it's already being addressed, I'm not planning to spend a lot of
time on this and will probably just wait for 2.4.4 to get this fixed
for real.  In the meantime, expect occasional crashes with 2.4.3.  If
you don't like this, you may want to stay with 2.4.2 for now (or
scream loudly and we can look into fixing it for ia64 before 2.4.4
shows up).

	--david

