From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 28 Mar 2001 17:59:53 +0000
Subject: Re: [Linux-ia64] Deterimining EFI device number within Linux?
Message-Id: <marc-linux-ia64-105590693005364@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005359@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005359@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matt,

On Tue, Mar 27, 2001 at 05:18:50PM -0600, Matt_Domsch@Dell.com wrote:
> Does anyone know how to determine the EFI Device Number (such as 0x80) for a
> disk known as /dev/sda, under Linux (ideally from user-space, but I'd take a
> kernel-space trick too)?  There's an equivalent problem in IA-32 which has
> no known solution.  I'm hoping there is for EFI<->Linux.

If you forget about the bios 0x80 stuff, EFI uses device paths as can be
seen from the EFI shell by typing map. The text on the righthand side is 
the device path. It is based on some PCI, ACPI stuff. There is no connection
with the Linux way of doing things.

For instance:
fs0  : VenHw(Unknown Device:80)/HD(Part1,Sig00000000)

If you forget about fs0, there is no a priori way to map
VenHw(Unknown Device:80)/HD(Part1,Sig00000000) to /dev/sda. You would have
to know how (the order) the devices get scanned by both EFI and Linux to make 
the connection. As David pointed out, your best chances are to reconstruct
the hardware path to the device (including partitions) and to somehow convert
this into the equivalent EFI device path.


-- 
-Stephane

