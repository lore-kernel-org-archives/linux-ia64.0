From: Alex Williamson <alex_williamson@hp.com>
Date: Wed, 18 Dec 2002 19:26:56 +0000
Subject: Re: [Linux-ia64] RTC support on ia64
Message-Id: <marc-linux-ia64-105590709805611@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805600@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805600@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Joel GUILLET wrote:
> 
> The RTC legacy hardware seems to be on the i870 chipset. And if you don't
> have this one, you may not be able to use it.

   Obviously, but that wasn't really my point.  What I'm really
after is that on ia64 you really shouldn't be assuming legacy
hardware is present and blindly poking port space and setting up
irqs based on that assumption.  Not only might it not work on
a legacy free box, it might break other things.  I think you
really need to make some attempt to determine if the hardware is
out there, and I don't see one in the rtc_init path.

	Alex

--
Alex Williamson                                  Linux Development Lab
alex_williamson@hp.com                                 Hewlett Packard
970-898-9173                                          Fort Collins, CO

