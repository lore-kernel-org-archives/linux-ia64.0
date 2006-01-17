From: Andi Kleen <ak@suse.de>
Date: Tue, 17 Jan 2006 14:05:32 +0000
Subject: Re: [discuss] [PATCH/RFC] Unify mapping from PXM to node id.
Message-Id: <200601171505.32933.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060117205442.5B9A.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060117205442.5B9A.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: discuss@x86-64.org
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, ACPI-ML <linux-acpi@vger.kernel.org>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>, "Brown, Len" <len.brown@intel.com>

On Tuesday 17 January 2006 13:36, Yasunori Goto wrote:
> Hello.
>
> This patch is to unify mapping from pxm to node id as a common code.
> In current code, i386, x86-64, and ia64 have its mapping by each own code.
> But PXM is defined by ACPI and node id is used generically. So,
> I think there is no reason to define it on each arch's code.
> This mapping should be written at drivers/acpi/numa.c.
>

> Please comment.

The array is unnecessary big - PXMs are only 8bit so it could be u8.

Looks ok to me on x86-64 in principle, except that the __devinits should
be probably __cpuinits. I haven't tested/compiled it though

-Andi
