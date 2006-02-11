From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Sat, 11 Feb 2006 21:25:11 +0000
Subject: Re: some new unaligned access while booting ia64 (HP rx2620)
Message-Id: <200602111425.11897.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F05AD5C61@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F05AD5C61@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "Moore, Robert" <robert.moore@intel.com>, Thomas Renninger <trenn@suse.de>, "Brown, Len" <len.brown@intel.com>, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

On Friday 10 February 2006 15:58, Luck, Tony wrote:
> > That looks good. You'll probably need to increase your dmesg buffer
> > or send the output to a serial port, since you will get megabytes
> > of info.
> 
> I only have a serial port on this machine ... but all the interesting
> output happens before it is enabled ... i.e. is buffered up in log_buf
> until the serial console is brought online.

This is because when you use "console=ttyS0", we can't use that
console until we know which device will be "ttyS0".  We learn
that when the serial driver discovers the devices, which is
fairly late.  (Most other architectures have hard-coded "ttyS0
is at I/O port 0x3f8" assumptions, which lets them start the
console earlier.)

But since you have an HP box with an HCDP, you can remove the
"console=ttyS0" argument (after making sure that you have only
the desired port enabled for EFI console output).  In this case,
the HCDP table tells us the port address, so we can enable the
console very early.

Alternatively, you can use "console=uart,mmio,0x<address>", which
will also work very early.  This works on any  box, since it doesn't
depend on the HCDP, but you do have to figure out the UART address
(it's printed when the serial driver discovers the port).

Bjorn
