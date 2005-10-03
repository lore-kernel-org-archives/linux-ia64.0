From: Greg Edwards <edwardsg@sgi.com>
Date: Mon, 03 Oct 2005 14:44:08 +0000
Subject: Re: [PATCH] set altix preferred console
Message-Id: <20051003144408.GK3264@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050930200422.GD13855@sgi.com>
In-Reply-To: <20050930200422.GD13855@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 30, 2005 at 03:20:11PM -0600, Bjorn Helgaas wrote:
| I think what *should* happen is that we should discover VGA
| devices by PCI enumeration, and the iobase/membase information
| would come from the ACPI description of the PCI root bridges.
| Then we could support multiple VGA devices, and the PCDP could
| point to one of them to be used as the console.
| 
| The VGA code in the kernel is a long ways from that.  But your
| firmware should provide the vga_console_{iobase,membase} data
| somewhere besides the PCDP.  Can you do something in ia64/sn
| to dig it out?

Thanks for the info and suggestion, Bjorn.  I think we should be able to
come up with something in sn-specific code.  I'll talk to our I/O guys
and see what we can come up with.

Greg
