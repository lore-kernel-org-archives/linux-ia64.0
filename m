From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 26 Jul 2002 16:42:23 +0000
Subject: RE: [Linux-ia64] new problem with memcpy_mck routines
Message-Id: <marc-linux-ia64-105590701905838@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905782@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905782@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 24 Jul 2002 16:59:37 -0700, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> It turns out that the screen corruption that Jesse and Alex saw
  Ken> was due to a bug in generic console vga code.  The scrup()
  Ken> functions uses memcpy to copy overlapping memory area.  By
  Ken> definition, memcpy() must not be used for overlapping memory
  Ken> areas.  This patch changed that to memmove() which handles
  Ken> overlapping areas gracefully.  This also fixes the same screen
  Ken> corruption when switching from X server to text mode.

  Ken> There is nothing wrong with new memcpy function.

Ah, that's good!  Thanks for confirming this.


  Ken> One other question, who is the maintainer for the console code?
  Ken> This should go into the base as it is not ia64 specific and
  Ken> could potentially trigger on other architectures.

Have you tried Martin Mares?  He is listed as SVGA maintainer and has
at least on occasion hacked on that file.  In any case, I'd definitely
cc lkml so that others can see this report, too.

	--david

