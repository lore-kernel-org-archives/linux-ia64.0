From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 16 Jan 2003 22:53:25 +0000
Subject: Re: [Linux-ia64] ia64_fls patch (asm-ia64/bitops.h)
Message-Id: <marc-linux-ia64-105590709805706@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805705@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805705@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 16 Jan 2003 17:48:33 -0500, "MAGENHEIMER,DAN (HP-FtCollins,ex1)" <dan_magenheimer@hp.com> said:

  Dan> Here's a patch for a mistake in ia64_fls in bitops.h.  The result
  Dan> was incorrect (64) for inputs starting at 0xfffffffffffffc00.
  Dan> I've also fixed the comment and the return value (which was -65535!)
  Dan> for a zero input value.

No!  The comment was correct: the function is UNDEFINED for an argument of 0.

The rest looks good though.

	--david

