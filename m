From: Branden Robinson <branden@progeny.com>
Date: Thu, 26 Jul 2001 20:35:09 +0000
Subject: [Linux-ia64] XFree86 4.1.0, Linux/ia64, and various video cards
Message-Id: <marc-linux-ia64-105590693005931@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's a report on some hardware testing we've been doing at Progeny:

The tests were conducted using a patched version of 4.1.0 for Debian and
Progeny that works around a problem with PIC symbols being absent in static
libraries, which powerpc, ia64, and hppa (among possible others) do not
tolerate.  At the same time, PIC symbols in X server modules cause the X
server to segfault.  I'll be submitting this patch to XFree86 shortly.

The tests were run on an HP Workstation i2000.

1) NVidia Quadro2 AGP
	Works fairly well.  Not a surprise since this is the stock card for
	this machine.

2) 3Dfx Voodoo3 3000 PCI
	Works.

3) 3Dfx Voodoo5 5500 AGP
	Didn't work at all; not even recognized by the BIOS on the machine.
	I won't say any more about this since it's clearly not (yet) a
	software problem.

4) S3 Trio64V2/DX PCI
	BIOS seemed somewhat confused by this card, and beeped 5 times
	before driving it.  It also appeared to believe that the card was
	grayscale only.  The Linux console driver had no problems sending
	color information to the card in VGA text mode.

	The 4.1 XFree86 server doesn't support this chipset, but there is a
	driver in CVS for it, which I imagine I'll get a chance to test.

5) ATI Rage Pro Turbo AGP
	The server crashed on startup with a SIGILL; a log file is
	attached.  I presume the atimisc driver has not yet been ported to
	ia64.

6) Rendition V1000 PCI (Creative Labs "3D Blaster")
	The server started, switched the card to graphics mode, but failed
	to completely initialize it.  On the X server's VT there was
	nothing but a blank screen.  A VT switch back to vc1 was possible,
	where I was greeted by a display like that you get on old multisync
	monitors that didn't shut off when you got out of sync range.
	I.e., the display was diagnoally skewed and very noisy; however the
	display manager's greeter was recongizable and the colors appeared
	to be correct.  My guess is that there are some issues with the VT
	switching and CRTC code; otherwise this driver might be in good
	shape.  A logfile is attached.

7) SiS 6326 PCI
	This card did better than I expected given some legendary problems
	with SiS video chipsets generally.  The greeter widget was rendered
	incorrectly, with two copies horizontally offset and a ragged,
	indistinct boundary with lots of analog noise betweeen them.
	Interestingly, the red Debian swirl that I should have seen was
	geometrically correct, but green on the left copy of the greeter
	and blue on the right.  A log file is attached.

				------------------------------------------
				|     greeter 1     :       greeter2     |
				|                    :                   |
				|                   :                    |
				|                  :                     |
				|                   :                    |
				------------------------------------------

-- 
Branden Robinson          | GPG signed/encrypted mail welcome
branden@progeny.com       | 1024D/9C0BCBFB
Consultant                | D5F6 D4C9 E25B 3D37 068C
Progeny Linux Systems     | 72E8 0F42 191A 9C0B CBFB

