From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 16 Jan 2002 18:21:34 +0000
Subject: RE: [Linux-ia64] PXE Boot
Message-Id: <marc-linux-ia64-105590698805846@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mike,

I saw the same thing a few months ago when I tried it (even when
I replaced the elilo.efi with a 1-byte file, I still got the same
error ... so the size of the file isn't the issue).  I didn't
get around to chasing this ... but I wondered whether there was
a failure to communicate the size correctly between the boot server
that I was using (Lion running linux ... I forget which versions of
dhcp and tftpd were present, and that machine has been re-installed
so I can't check) and the bigsur that I was trying to boot.

-Tony Luck

-----Original Message-----
From: Michael Madore [mailto:mmadore@turbolinux.com]
Sent: Wednesday, January 16, 2002 10:57 AM
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] PXE Boot


Hi,

I'm trying to boot a Big Sur workstation (Firmware 117C) via the
network.  The workstation receives an address via dhcp and when starting
to download elilo.efi I get the following error message:

PXE-E05: Download buffer is smaller than requested file.
Load of PXE boot failed:  File not found

Does this message really indicate the buffer is to small, or is this a
symptom of a different problem?

Mike

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

