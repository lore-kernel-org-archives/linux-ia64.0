From: Erich Focht <efocht@ess.nec.de>
Date: Wed, 21 Aug 2002 13:04:30 +0000
Subject: Re: [Linux-ia64] [RFC] Remove MCA dump?
Message-Id: <marc-linux-ia64-105590701905967@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905964@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905964@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 21 August 2002 13:51, Matthew Wilcox wrote:
> The MCA handler is completely useless.  If I crash the machine and
> forget to clear the MCA dump in firmware, at the next boot Linux dumps
> the registers (in a hard-to-understand style) and hangs.  In its current
> state, I'd rather it simply weren't in the kernel at all.

I'd also like to object to the statement above. The dumped registers are
fine and enough to get an idea where the system was and what it was doing.
My machines don't hang after the reboot. I'm using kdb and LKCD so
init_handler_platform looks completely different from yours, anyhow
I don't understand why that code should be executed _after_ you reboot.
Shouldn't the MCA logs come from ia64_log_print?

Regards,
Erich


