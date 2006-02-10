From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 10 Feb 2006 22:58:31 +0000
Subject: RE: some new unaligned access while booting ia64 (HP rx2620)
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05AD5C61@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
In-Reply-To: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Moore, Robert" <robert.moore@intel.com>, Thomas Renninger <trenn@suse.de>, "Brown, Len" <len.brown@intel.com>
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

> That looks good. You'll probably need to increase your dmesg buffer
> or send the output to a serial port, since you will get megabytes
> of info.

I only have a serial port on this machine ... but all the interesting
output happens before it is enabled ... i.e. is buffered up in log_buf
until the serial console is brought online.

I made log_buf as big as I could (2^21 bytes is the biggest it would
let me go), and that is not enough for all the ACPI messages ... so the
initial part where the unaligned messages were printed was lost in the
wraparound before anything could be dumped to the serial port.

Now I've got network problems in the lab ... when I can reconnect to
my systems, I'll change lib/Kconfig.debug to allow a bigger log_buf
and try again.

-Tony
