From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 17 Dec 2002 21:57:07 +0000
Subject: Re: [Linux-ia64] RTC support on ia64
Message-Id: <marc-linux-ia64-105590709805603@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805600@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805600@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Alex" = Alex Williamson <alex_williamson@hp.com> writes:

Alex> Joel, Does this provide more functionality than the EFI RTC?
Alex> Concerns I have w/ it on ia64 is that the rtc driver assumes you
Alex> have a legacy rtc at the legacy irq and port address.  This
Alex> won't work on HP zx1 boxes, the legacy hardware doesn't exist.
Alex> In the future, there's a possibility that the port address could
Alex> be allocated to non-legacy purposes.  Maybe ACPI could tell you
Alex> if you have a legacy RTC, it could at least tell you if you
Alex> support PC/AT compatible interrupts.  Thanks,

Yes it does.  There's no way to get a regular interrupt into user
space from the EFI RTC.

I've been using the PMU to generate regular interrupts, and have a
locally-modified amlat benchmark that does that.

--
Dr Peter Chubb				    peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories, all almost the same.



