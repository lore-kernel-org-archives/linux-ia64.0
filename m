From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 14 May 2003 02:40:50 +0000
Subject: Re: [Linux-ia64] Dump driver module
Message-Id: <marc-linux-ia64-105590723705773@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705751@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705751@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 14 May 2003 12:32:17 +1000, Martin Pool <mbp@samba.org> said:

  Martin> So for a really reliable dump, you'd want to check and "lock
  Martin> down" these variables at startup into a region of memory not
  Martin> easily changed by the kernel, and accessible by EFI.  NVRAM?
  Martin> I don't know if there's anything suitable on IPF.

EFI provides (persistent) environment variables for this purpose.
Don't know how well they're protected, typically, but that's probably
more of an implementation issue than anything else.

  Martin> It would be an interesting project, although since network
  Martin> dumps run a lower risk of clobbering filesystems they're
  Martin> probably a smarter design.  It would be cool to do it in
  Martin> EFI, if that's possible.

"Smart" is relative. I'm typing this on an Itanium box which doesn't
have anything on the network that could serve as a dump device (it's
own disk would be fine, though).

	--david

