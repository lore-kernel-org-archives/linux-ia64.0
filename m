From: "Surekha.PC" <surekhap@cisco.com>
Date: Thu, 01 Apr 2004 06:58:11 +0000
Subject: linux IA 64 kernel does not load
Message-Id: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAABgAAAAAAAAANoIxZIFzbEaqwjJgytz2AeKAAAAQAAAAmkF5UEceNEeWYC4rhFjk+QEAAAAA@cisco.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


 Hi,

 I am attempting to boot my itanium 64-bit machine using 2.4.20 linux IA 64
kernel. I followed the following steps to compile the kernel using gcc 2.94:
Install the linux 2.4.20 kernel sources Apply the IA 64 kernel patch Compile
the kernel using the following commands:-
    export LANG=C
    make mrproper
    make CC=/usr/bin/gcc.org menuconfig
    make CC=/usr/bin/gcc.org dep clean vmlinux
 
Then, I manually copied the vmlinux and System.map from
/usr/src/linux-2.4.20/ into /boot/efi/ and created the corresponding links
to vmlinuz and initrd.img into /boot. 
Also, there is no lilo but elilo. So I had to boot the machine, go into the
EFI shell and bring the new vmlinuz-2.4.20 entry in the elilo.conf file into
effect. However, on selecting vmlinuz-2.4.20 at the elilo prompt, the system
hangs at the first step itself. It displays "Loading linux-2.4.20 .... \"
and hangs in the load process itself. 
 
Thanks and appreciate any help,
Surekha

> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org 
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of 
> Francois Wellenreiter
> Sent: Thursday, April 01, 2004 11:57 AM
> To: Bjorn Helgaas
> Cc: Luck, Tony; linux-ia64@vger.kernel.org
> Subject: Re: Abnormal behaviour towards "INIT" interrupt management
> 
> 
> 
> > 
> >>All the processors call the "ia64_monarch_init_handler",
> >>the result is that the same trace appears many times (1 per CPU in 
> >>fact) and a kernel oops occurs (I think it is due to a concurrent 
> >>access to the same stack without any lock mechanism).
> > 
> > 
> > What kind of machine is this?
> 
> I've done my tests first on Tiger4 (with a SAL version 3.00) 
> and after on a Bull NOvaScale 5160. These tests went to the 
> same results...
> 
> > Linux registers different OS_INIT
> > procedures for the monarch and non-monarch processors, so it sounds 
> > like a SAL bug if more than one CPU calls 
> ia64_monarch_init_handler().
> 
> That's what I fear.
> 
> 
> 
> 		Francois WELLENREITER
> 
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-ia64" in the body of a message to 
> majordomo@vger.kernel.org More majordomo info at  
http://vger.kernel.org/majordomo-info.html

