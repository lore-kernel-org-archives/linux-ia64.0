From: "Jim Hollenback" <jholly@cup.hp.com>
Date: Thu, 14 Mar 2002 21:17:26 +0000
Subject: [Linux-ia64] readv() return and errno
Message-Id: <marc-linux-ia64-105590701905285@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In doing some testing on the project I'm working on I came across
something that is causing a bit of confusion on my part.

According to readv(2) EINVAL is returned for an invalid argument.
The examples given were count might be greater than MAX_IOVEC or
zero. The test case I am working with has count = 0 and I get return
of 0 and errno 0 instead of the expected -1 and erron EINVAL.

Am I missing something?

Thanks!

Jim Hollenback

