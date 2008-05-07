From: Roland McGrath <roland@redhat.com>
Date: Wed, 07 May 2008 23:23:18 +0000
Subject: RE: [BUG?][2.6.25-mm1] sleeping during IRQ disabled
Message-Id: <20080507232318.2BCDE1DF9F5@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On other machines, the assembly code does: disable interrupts; check TIF ||
return to user; (else) TIF_has_work: enable interrupts; call out to C.

For ia64, it's your business whether the assembly code reenables interrupts
or do_notify_resume_user does it from C.  But it certainly is expected to
have been done before you call into the signals code.


Thanks,
Roland
