From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 22 Jun 2004 13:50:10 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200406220950.10198.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, June 22, 2004 2:15 am, Grant Grundler wrote:
> Kernel command line: BOOT_IMAGE=scsi0:/EFI/debian/boot/vmlinuz-2.6.7
> root=/dev/sdb3 consoyS0 ro PID hash table entries: 4096 (order 12: 65536
> bytes)
> CPU 0: base freq 0.000MHz, ITC ratio/2, ITC freq00.000MHz+ppm
> Console: colour VGA+ 80x25

Did you have any MCA records after you rebooted?  This is about the time it 
should have chosen a default console device and started printing to it, so if 
it tried using the VGA console and you didn't have one, it may have just 
fallen over.  The MCA record would be pretty clear about that though...

Jesse
