From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Apr 2002 21:17:03 +0000
Subject: RE: [Linux-ia64] running X with 2.4.18 kernel
Message-Id: <marc-linux-ia64-105590701905501@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905497@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905497@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 23 Apr 2002 16:07:53 -0500, Matt_Domsch@Dell.com said:

  Matt> X needs to have an executable stack for scanpci to
  Matt> work.  After running David's program, it works fine for me.

BTW: a fix for the X server which will obviate the need for chatr has
been submitted by the Debian maintainer of the X11 package.  I'm not
tracking the status (too many other things to worry about), but I
expect that the X maintainers will eventually get around to fixing
this.

	--david

