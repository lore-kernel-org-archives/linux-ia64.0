From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 29 Jun 2005 21:13:50 +0000
Subject: RE: problem booting -mm2 kernel on rx2600
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03D0B52D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506291236.14024.bjorn.helgaas@hp.com>
In-Reply-To: <200506291236.14024.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>It just hangs after the "uncompressing" message.  But when I added
>
>	console=uart,mmio,0xff5e0000
>
>to see what was going on, it came all the way up!!!


Which made me notice that I didn't have any kind of "console="
on the boot line for this kernel.  Adding a "console=tty1" also
allows it to boot.

-Tony
