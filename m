From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 12 Dec 2002 19:14:31 +0000
Subject: Re: [Linux-ia64] fpswa logging redux
Message-Id: <marc-linux-ia64-105590709805555@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805545@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805545@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  Jesse> How about something like this then?  It just prints out the
  Jesse> isr in addition to the ip for the case of printk, and decodes
  Jesse> the right si_code for signals.  If this approach looks ok, I
  Jesse> can add trap decoding too.

Basically OK with me, however:

 o What's the point of declaring fp_fault_info in a header file?  It's
   used only in one place.

 o si_code is NOT a bitmask; it makes no sense at all for
   fp_fault_si_code() to OR multiple values together; this makes me
   highly suspicious that there is a misunderstanding somewhere...

 o Who defined FP_SWASST and FPE_DENORM?  I don't recall seeing them
   in the ia64 psABI and they definitely look ia64-specific, so their
   names should at least be prefixed by a double-underscore
   (siginfo.h).

 o If you add stuff to asm/siginfo.h, don't forget to update glibc (in
   sysdeps/unix/sysv/linux/ia64/bits/siginfo.h).

	--david

