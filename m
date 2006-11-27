From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Mon, 27 Nov 2006 08:48:45 +0000
Subject: Re: How to boot 2.6 kernel using hp ski simulator ???
Message-Id: <87ejrpjmvm.wl%peterc@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <9b33a9230611252149m4da2634akbd355f026759ac70@mail.gmail.com>
In-Reply-To: <9b33a9230611252149m4da2634akbd355f026759ac70@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: sudhnesh adapawar <sudhnesh@gmail.com>
Cc: lia64-sim@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernelnewbies@nl.linux.org


Please check out http://www.gelato.unsw.edu.au/IA64wiki/SkiSimulator
for lots of info on Ski.

It works fine with Linux 2.6; and hugepage work too.

> 1) I used 'make ARCH=ia64 menuconfig' to configure and followed the
> steps to get kernel image of version 2.6 ! I also selected the generic
> type as Ski-simulator and also selected the HP-ski drivers something
> simscsi,etc.etc.

I suggest you start with
	make sim_defconfig

Your symptoms look like a misconigured or misbuilt vmlinux.  The sim_defconfig

If you're running on IA32, then you need something like:
	make CROSS_COMPILE=ia64-linux-gnu ARCH=ia64 boot 
to build kernel and bootloader.

You need to get or build yourself a disk image.  Instructions for
building at http://www.gelato.unsw.edu.au/IA64wiki/skidiskimage 




--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia
