From: "Hall, Jenna S" <jenna.s.hall@intel.com>
Date: Wed, 21 Aug 2002 14:59:51 +0000
Subject: RE: [Linux-ia64] [RFC] Remove MCA dump?
Message-Id: <marc-linux-ia64-105590701905968@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905964@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905964@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yes they should.  There is no reason your system should hang *after* the
reboot if the MCA occurred before the reboot.  I also wonder if you've got
some old hardware or firmware...please let me know what HW/FW you're running
and I'll try to figure out why your system behaves this way upon reboot.

The MCA code is certainly not finished.  The logging is there, but the
recovery for MCAs is still in development by Intel and Bull engineers.  You
can disable the MCA logging in the .config but if your HW/FW is behaving
correctly it should not matter...besides, the logs do provide valuable
information in the case of a hardware failure (eg. flaky memory DIMM causing
sporadic hardware-corrected MCAs).

Further, the init_handler_platform() procedure is only called *during* an
INIT event - which is fatal and wouldn't be helped anyway if the MCA
recovery code was perfectly healthy.  The expected behavior of this
procedure is as you described - hang if no KDB enabled, jump into KDB if it
is enabled.  There is definitely something else going on with your system
beyond a simple MCA that occurred before the reboot.

Jenna

 -----Original Message-----
From: 	Erich Focht [mailto:efocht@ess.nec.de] 
Sent:	Wednesday, August 21, 2002 6:05 AM
To:	Matthew Wilcox; linux-ia64@linuxia64.org
Subject:	Re: [Linux-ia64] [RFC] Remove MCA dump?

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


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

