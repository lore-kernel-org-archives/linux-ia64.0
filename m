From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 30 Apr 2001 23:54:14 +0000
Subject: [Linux-ia64] status for 2.4.4
Message-Id: <marc-linux-ia64-105590693005494@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just a quick heads-up: I was hoping to release a 2.4.4 based patch
today but, unfortunately, several unexpected issues cropped up.  Most
importantly, something is currently wrong in the USB subsystem which
prevents 2.4.4 from booting when a USB device is plugged in (this is
not a 4GB memory limit issue).  Also, there are some odd x86 emulation
failures which I cannot explain yet.  For example, mozilla used to
work fine on my latest (unreleased) 2.4.3 patch and with 2.4.4 it
fails consistently.  I'll be on travel for most of the rest of the
week, but I'll try to at least send out a test patch for 2.4.4 asap.

	--david

