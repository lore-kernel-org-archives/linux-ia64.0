From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 08 Oct 2001 23:42:15 +0000
Subject: [Linux-ia64] Re: prctl patch for fpu faults
Message-Id: <marc-linux-ia64-105590698805302@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 8 Oct 2001 14:57:00 -0700, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> I think you mentioned awhile ago that a patch like this might be
  Jesse> welcome.  Well, here it is.  It's diff'd against 2.4.10 with the ia64
  Jesse> patch.  Please let me know if you find problems with it.

The patch looks mostly good to me.  However, why did you get rid of
the rate limiting code?  I think we still want that.

	--david

