From: "Saxena, Sunil" <sunil.saxena@intel.com>
Date: Mon, 09 Oct 2000 15:23:24 +0000
Subject: RE: [Linux-ia64] avoiding float underflow software assist
Message-Id: <marc-linux-ia64-105590678205557@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205556@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205556@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Pete,
I have copied Marius who should be able to help answer your question.
Thanks
Sunil

-----Original Message-----
From: Pete Wyckoff [mailto:pw@osc.edu]
Sent: Monday, October 09, 2000 8:12 AM
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] avoiding float underflow software assist


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

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


