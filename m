From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 10 Nov 2003 17:17:36 +0000
Subject: Re: Bjorn Tree (2.4 IA64) + ACPI Testing  Report
Message-Id: <marc-linux-ia64-106848468725564@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106699413304707@msgid-missing>
In-Reply-To: <marc-linux-ia64-106699413304707@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 05 November 2003 8:24 am, Yu, Luming wrote:
> I pull it yesterday. It boot and power off fine on my lion.  PS2 mouse, keyboard, Netcard, Scsi devices work fine.
> 
> But there are something unusual:
> 
> 1. After login, the dmesg return below message.
> ...
> ifup-post(864): <sc1236(0,1008,0,20000000000d5b20)>
> ifup-post(753): <sc1236(0,1008,0,20000000000d5b20)>
> initlog(752): <sc1236(0,1008,0,20000000000a5b20)>
> initlog(865): <sc1236(0,1008,0,20000000000a5b20)>
> sysctl(866): <sc1236(fffffffffffffffe,3,0,0)>

These are some unimplemented syscalls.  There was some discussion
earlier about turning off those messages, but I haven't seen any
actual patches.

> 2. Some error message in serial console
> 
> ACPI: PCI Root Bridge [PCI0] (00:00)
> alloc 0x0-0xcf7 from PCI IO for PCI Bus 00:00 failed

You'd probably have to add some debug code to add_window()
to chase this down, but I think it's harmless.  I've noticed that
firmware often reports those ranges incorrectly.

Bjorn

