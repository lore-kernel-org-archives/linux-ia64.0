From: Andrew Morton <akpm@osdl.org>
Date: Sat, 27 Jan 2007 01:10:48 +0000
Subject: Re: [PATCH 1/3] - Altix: ACPI SSDT PCI device support
Message-Id: <20070126171048.5f0bf293.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061115152454.6047.64973.sendpatchset@attica.americas.sgi.com>
In-Reply-To: <20061115152454.6047.64973.sendpatchset@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Keller <jpk@sgi.com>
Cc: linux-acpi@vger.kernel.org, len.brown@intel.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, pcihpd-discuss@lists.sourceforge.net, gregkh@suse.de, linux-kernel@vger.kernel.org, ayoung@sgi.com, jes@sgi.com

On Wed, 15 Nov 2006 09:24:54 -0600
John Keller <jpk@sgi.com> wrote:

> Add SN platform support for running with an ACPI
> capable PROM that defines PCI devices in SSDT
> tables. There is a SSDT table for every occupied
> slot on a root bus, containing info for every
> PPB and/or device on the bus. The SSDTs will be
> dynamically loaded/unloaded at hotplug enable/disable.

An additional 600kb of diff has just popped up in the ACPI tree, so none of
this patch applies any more.  I'll need to drop it again, sorry.

It's been over two months - I'm not sure why things are so difficult for
this patchset.

