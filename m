From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 17 Jan 2002 05:20:37 +0000
Subject: RE: [Linux-ia64] latest MCA logging patch
Message-Id: <marc-linux-ia64-105590698805864@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805745@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805745@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  Jenna> To be on the safe side, I have re-instated the spinlock
  Jenna> around SAL runtime calls.  During MCA handling, however, we
  Jenna> will make SAL calls without the spinlock.  If the SAL version
  Jenna> happens not to be re-entrant then it will just increase the
  Jenna> chances of a system crash - which is provided for anyway in
  Jenna> the MCA handler code.

  Jenna> Please let me know if this is acceptable.  Here is the new
  Jenna> patch.

I tried to apply the patch, but it failed because your mailer wraps
long lines.  Perhaps you could try sending it as a MIME attachement.

	--david

