From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 Feb 2003 17:52:43 +0000
Subject: Re: [Linux-ia64] strange performance behaviour with floats
Message-Id: <marc-linux-ia64-105590709805886@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805852@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805852@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 Feb 2003 09:35:02 +0100, Volker Birk <vb@ebios.de> said:

  Volker> On Wed, Feb 19, 2003 at 11:09:36AM -0800, David Mosberger
  Volker> wrote: Hello, I'm wondering about the strange behaviour of
  Volker> the Linux scheduling on my rx5670:

  >> Can you reproduce the behavior with a standard 2.4.xx ia64 kernel
  >> (not with Red Hat's heavily patched kernel)?

  Volker> That is a standard 2.4.xx ia64 kernel (with ia64 patches
  Volker> from kernel.org).

  Volker> bronto:~ # uname -a Linux bronto 2.4.19 #11 SMP Sat Nov 2
  Volker> 18:47:02 CET 2002 ia64 GNU/Linux bronto:~ #

Hmmh, that's really strange.  I assume you realize that your
test-program doesn't really do what the source code suggests (the
loop-body gets optimized away), but regardless the high variation
you're seeing seems wrong.  Are you re-directing the kernel console to
a serial line?  If so, make sure there is no logging activity when the
program runs slower (especially a slow baud-rate can "stall" the
kernel for non-trivial amounts of time).

	--david

