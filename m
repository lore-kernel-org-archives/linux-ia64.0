From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 25 Apr 2002 22:37:11 +0000
Subject: [Linux-ia64] /proc/cpuinfo change
Message-Id: <marc-linux-ia64-105590701905528@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Since McKinley is now officially known as "Itanium 2", I'd
like to change the /proc/cpuinfo accordingly.  That is, the
family line would read:

family     : Itanium 2

I don't know of any applications that are affected by this, but I
thought it would be good to give a heads-up (I'm not planning to
change any of the CONFIG options; that would be too much idle work).

	--david

