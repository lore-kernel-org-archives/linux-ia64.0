From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Mon, 21 Nov 2005 22:38:18 +0000
Subject: Re: Fix asm constraint in put_user
Message-Id: <ed5aea430511211438i3d6187a9if61750bb73ae8583@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je7jb2nigc.fsf@sykes.suse.de>
In-Reply-To: <je7jb2nigc.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 11/21/05, Andreas Schwab <schwab@suse.de> wrote:

> There is nothing worth clobbering here.  The memory written to is
> completely separate to anything GCC knows about.  The old version didn't
> clobber either.

That's usually true, but I don't think it's always true.  Consider the
case where put_user() is used to write kernel memory (which happens in
the ia32 emulation layer, for example).  I agree it's probably
extremely unlikely for this to trigger a real problem (especially
considering that the kernel is compiled without strict aliasing) but
still, the safe thing to do would be to add a "memory" clobber if
there is no better alternative.

  --david
--
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
