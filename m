From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 27 Sep 2006 11:57:08 +0000
Subject: Re: KDB blindly reads keyboard port
Message-Id: <20060927115707.GQ5017@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200609261354.30722.bjorn.helgaas@hp.com> <5239.1159325150@kao2.melbourne.sgi.com>
In-Reply-To: <5239.1159325150@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@sgi.com>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, Sep 27, 2006 at 12:45:50PM +1000, Keith Owens wrote:
> No support for legacy I/O ports could be a bigger problem than just
> KDB.  To fix just KDB, apply this patch over kdb-v4.4-2.6.18-common-1 and add
> 'kdb_skip_keyboard' to the boot command line on the offending hardware.

Why can't you use acpi_kbd_controller_present instead of introducing a
new option?
