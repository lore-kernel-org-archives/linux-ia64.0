From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Thu, 13 Nov 2003 03:14:14 +0000
Subject: Re: Latest 2.6 IA64 Baseline (Mosberger) testing report (Boot hang)
Message-Id: <marc-linux-ia64-106869327020510@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863716316469@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863716316469@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It boots fine on Lion here, it looks like you might be using the wrong config?
The config you attached is for ZX1/McKinley.

Matt


On Wed, Nov 12, 2003 at 07:37:22PM +0800, Yu, Luming wrote:
> ACPI Test Report  for 2.6 ia64 kernel 
> ============> Hardware Configuration:
> -----------------------
> System Name: ACPI-LION
> System Type: 4 way 800M Itanium, Lion
> M/B revision: N/A
> Processor version: N/A
> Firmware Versions: N/A
> I/O configuration summary:
> 	QLogic QLA12160, Seagate ST39205LC boot drive
> 	IDE floppy and CDROM
> 	Serial console
> 	PS/2 keyboard and mouse
> 	USB mouse
> 	Ethernet Pro 100
> 
> Software Configuration:
> -----------------------
> 	1.Bk pull form http://lia64.bkbits.net/linux-ia64-2.5 on 11/11 (Shanghai time)
> 
> 	Successfully automerged by bk without out any manually work.
> 
> ACPI Features Tested: (prioritized).
> --------------------
> 1. Boot 			hang
> 
> Kernel hang after message:
>  <<2.6.config.ZIP>> 
> "ELILO boot : Loading vmlinux... Done"
> 
> Thanks,
> Luming
> 


