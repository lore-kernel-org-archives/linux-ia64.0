From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 01 Apr 2003 20:28:26 +0000
Subject: [Linux-ia64] Re: [PATCH] sal calls w/o taking sal_lock
Message-Id: <marc-linux-ia64-105590723705378@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 1 Apr 2003 10:06:44 -0800, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> This patch adds SAL_CALL_NOLOCK so that platforms may call the SAL
  Jesse> without taking a lock, if appropriate.  The ia64_sal_mc_rendez() has
  Jesse> been changed to use it, since it won't return until all CPUs have been
  Jesse> rendevoused by the SAL, if I understand correctly.  It's also used by
  Jesse> various SN specific SAL routines that access the system controllers
  Jesse> and might be useful to other plaforms.

http://lia64.bkbits.net:8080/to-linus-2.5/cset@1.1113?nav=index.html

	--david

