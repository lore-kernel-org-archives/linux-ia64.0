From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 09 May 2003 23:20:26 +0000
Subject: Re: [Linux-ia64] [PATCH] 1/4 multi-ioport space support for 2.5
Message-Id: <marc-linux-ia64-105590723705713@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705599@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705599@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 24 Apr 2003 16:25:26 -0600, Bjorn Helgaas <bjorn_helgaas@HP.COM> said:

  Bjorn> 3 add support for /proc/iomem and /proc/ioports

I'm suspecting this patch may be causing me some grief on a Big Sur.
What happens is that the qla1280 is configured to use I/O space by
default (no idea why that is the case, apart from a small buglet in
reading the base address) and with the patch applied, it fails to get
the range from 0x2000-0x20ff.

I can work around the problem by using memory-mapped I/O.  When I do
that, /proc/ioports looks like this:

$ cat /proc/ioports
00000000-000003af : PCI Bus 00:00
  00000060-0000006f : i8042
  00000170-00000177 : ide1
  000001f0-000001f7 : ide0
  00000376-00000376 : ide1
000003c0-000003df : vga+
000003e0-00000cf7 : PCI Bus 00:00
  000003f6-000003f6 : ide0
  000003f8-000003ff : serial
00000d00-00000fff : PCI Bus 00:00
00001000-00001fff : PCI Bus 00:00
  00001000-0000103f : eepro100
  00001040-0000105f : uhci-hcd
00002000-00002000 : PCI Bus 00:01
00003000-0000ffff : PCI Bus 00:03

Perhaps the problem is that the reported range for Bus 00:01 is empty?
Does this make any sense to you?  Perhaps it's a firmware problem.

	--david

