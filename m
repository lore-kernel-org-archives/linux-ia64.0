From: "Moore, Robert" <robert.moore@intel.com>
Date: Fri, 10 Feb 2006 23:07:10 +0000
Subject: RE: some new unaligned access while booting ia64 (HP rx2620)
Message-Id: <971FCB6690CD0E4898387DBF7552B90E0452B062@orsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
In-Reply-To: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Thomas Renninger <trenn@suse.de>, "Brown, Len" <len.brown@intel.com>
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

You may need to selectively enable/disable the debug trace during a
particular call.

I suspect that the problem is happening during the execution of the
ACPICA interface AcpiSetCurrentResources (aka
acpi_set_current_resources).

Here's the way I would do it:

Set a breakpoint on acpi_set_current_resources. When you get there,
enable debug output. When finished, disable debugging.

If this isn't possible with your debugger, you can always change the
source to enable/disable debugging at the start and end of
acpi_set_current_resources.

Bob


> -----Original Message-----
> From: Luck, Tony
> Sent: Friday, February 10, 2006 2:59 PM
> To: Moore, Robert; 'Thomas Renninger'; Brown, Len
> Cc: 'linux-acpi@vger.kernel.org'; 'linux-ia64@vger.kernel.org'
> Subject: RE: some new unaligned access while booting ia64 (HP rx2620)
> 
> > That looks good. You'll probably need to increase your dmesg buffer
> > or send the output to a serial port, since you will get megabytes
> > of info.
> 
> I only have a serial port on this machine ... but all the interesting
> output happens before it is enabled ... i.e. is buffered up in log_buf
> until the serial console is brought online.
> 
> I made log_buf as big as I could (2^21 bytes is the biggest it would
> let me go), and that is not enough for all the ACPI messages ... so
the
> initial part where the unaligned messages were printed was lost in the
> wraparound before anything could be dumped to the serial port.
> 
> Now I've got network problems in the lab ... when I can reconnect to
> my systems, I'll change lib/Kconfig.debug to allow a bigger log_buf
> and try again.
> 
> -Tony
