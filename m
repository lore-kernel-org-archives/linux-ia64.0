From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 28 Feb 2002 19:19:01 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905202@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 28 Feb 2002 15:40:53 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

>>>>> "David" = David Mosberger <davidm@hpl.hp.com> writes:
  David> The latest ia64 patch is now availabe at ftp.CC.kernel.org in
  David> /pub/linux/kernel/ports/ia64/v2.4/:

  Peter> With this patched kernel, one cannot configure the loop device when
  Peter> using the HP simulator.

  Peter> I moved the line that sourced the block-device config script outside
  Peter> the HP_SIM guards, as in the appended patch.

Hmmh, I'm a bit reluctant to do this, as it will pull in all the other
drivers, 99% of which won't build.  How about just including the
loopback prompt directly in the ia64 config?  If this works, send me a
patch and I'll include it.  (Yes, I realize that's kludgy, but
presumably this will all get cleaned up if and when the new kernel
configuration makes it into 2.5).

	--david

