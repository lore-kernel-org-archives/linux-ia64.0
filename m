From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 29 May 2002 15:01:41 +0000
Subject: Re: [Linux-ia64] NTP broken?
Message-Id: <marc-linux-ia64-105590701905613@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905591@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905591@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 29 May 2002 15:13:05 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Guess what.  After the reboot that I did to find out what the
  Peter> BIOS said, the kernel now reports the correct cpu clock
  Peter> frequency, and NTP works.

Are you running the latest firmware?  The clockfrequency is indeed
_measured_ by the firmware and there used to be occasional but large
errors in that measurement.  I thought newer firmware doesn't have
this problem any longer.  So, if you're not running the latest version
yet, it might be worth to update the firmware.

	--david

