From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 23 Jul 2007 16:05:59 +0000
Subject: RE: Linus' tree broken?
Message-Id: <617E1C2C70743745A92448908E030B2A01FA5278@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46A4B026.9030307@sgi.com>
In-Reply-To: <46A4B026.9030307@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Have anyone else had seen issues with the Linus git tree failing to
> boot? I'm trying a pull as of this morning and it seems to hang when
> it's brining up the ethernet devices.
>
> It's not locking up, just the boot scripts never continues - happens
> both on SLES10 and FC7 roots :(
>
> Just wanted to check before spending real time on it.

Pulled Linus' tree (the -rc1 commit is at the head) and it built
and booted on my tiger.  Only new strange stuff in the dmesg is a
lot of

ACPI Exception (processor_throttling-0084): AE_NOT_FOUND, Evaluating _PTC [20070126]
ACPI Exception (processor_throttling-0147): AE_NOT_FOUND, Evaluating _TSS [20070126]

messages (this pair of message repeats 16 times)

-Tony
