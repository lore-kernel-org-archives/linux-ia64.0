From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 19 Jan 2004 16:00:00 +0000
Subject: Re: dma restriction on Itanium 2
Message-Id: <1074527999.1833.86.camel@wilson.home.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1074304095.6384.13.camel@kbiswas-dt.s2iotech.com>
In-Reply-To: <1074304095.6384.13.camel@kbiswas-dt.s2iotech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2004-01-16 at 20:58, Grant Grundler wrote:
> I'm hoping someone who is better at decoding MCA data can
> take a quick look at the data you posted earlier. If no one
> else does by next week, I'll work on it then.

   I took a stab at it, but I don't have my rope to slot decoder ring
handy.  It's a combination of parity errors and iommu translation
errors.  Here's what I get:

Error Status: 0x4a1800
        ERR_ERROR Detecton of PATH_ERROR
        Control: detected on control signal
        Responder: responder detected
        Overflow
Error Type: 0x2
        System Error

This was detected on bus 0x40, which according to lspci has nothing
plugged into it.  Potential stray address down the rope?

Error Status: 0xa1800 - Same as above w/o overflow
Error Type: 0x2
Bus ID: 0x60

Nothing plugged into this slot either

Error Status: 0x91600
        ERR_PARITY Bus Parity Error
        Address: detected on address
        Requestor detected

I beleive this one is on bus 0x80.  The OEM data confirms a parity error
on rope 4.

Error Status: 0x91100 ERR_MAP - Virt address not found in iotlb/iopdir

This one looks to be on rope 3, bus 0x60.  The OEM data shows the DMA
target address as 0x8000000042448684.  The next one is the same thing on
rope 3 to 0x800000004ee68a00.  Following that is another parity error on
rope 3.

The log show the same error record id twice (22843435).  RHEL 3 has a
bug in their CPE reporting/salinfo that never clears the CPE logs.  You
need to do it manually either by doing 'errdump clear' at the EFI shell
or by using the /proc/sal/cpe files.  I believe the latter is done by
'echo "clear 0" > /proc/sal/cpe/data'.  Since much of the data doesn't
appear to match your current slot config, it's possible we're looking at
old events here.  Thanks,

	Alex



