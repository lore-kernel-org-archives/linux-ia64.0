From: Pete Wyckoff <pw@osc.edu>
Date: Mon, 09 Oct 2000 15:12:16 +0000
Subject: [Linux-ia64] avoiding float underflow software assist
Message-Id: <marc-linux-ia64-105590678205556@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This little code snippet causes floating-point underflow during the
multiplication.

        float f, g;
	f = 1.3e-23;
	g = f * f;

The kernel handler catches the fault and fixes it up, but that's quite
slow.

Is there a way to have the hardware automatically ignore this condition
and force the result to zero on its own?

I've tried playing with fesetround() and fesetenv() to see if I could
manage it, to no avail.

kernel 2.4.0-test9
Turbolinux 000828 distro
B0 stepping hw

Thanks,
		-- Pete

