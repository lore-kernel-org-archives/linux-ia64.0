From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 22 Sep 2003 21:25:36 +0000
Subject: Re: Inefficient ia64 system call implementation in glibc
Message-Id: <marc-linux-ia64-106426598631350@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106398916511816@msgid-missing>
In-Reply-To: <marc-linux-ia64-106398916511816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 20 Sep 2003 15:01:26 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> "Jim Hull" <jim.hull@hp.com> writes:
  >> But my real issue with the performance of this code is not with
  >> sign-extend or the scheduling these instructions, it's with the
  >> break instruction.  I may be mistaken, but hasn't it been many
  >> months since David Mosberger implemented all the kernel
  >> infrastructure needed to support syscalls using the epc
  >> instruction?

  Andreas> It's only implemented in 2.6 so far.

No, the glibc support is completely orthogonal to the kernel support.
If glibc uses the new stubs on a kernel which doesn't support
kernel-entry via EPC, it will transparently fall back to using BREAK.

	--david
