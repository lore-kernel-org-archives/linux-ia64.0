From: "Deepak Kumar Gupta, Noida" <dkumar@noida.hcltech.com>
Date: Tue, 18 Nov 2003 06:39:29 +0000
Subject: problem in booting HP zx6000 with stock kernel 2.4.18
Message-Id: <marc-linux-ia64-106913694118596@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106840426422921@msgid-missing>
In-Reply-To: <marc-linux-ia64-106840426422921@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello everybody

I am trying to boot 2 CPU hp zx6000 machine (ia64, itanium2) from STOCK
kernel version 2.4.18. I have followed following steps.

1. I have downloaded the kernel from www.kernel.org . Also I have applied
ia64 patch (from
http://www.kernel.org/pub/linux/kernel/ports/ia64/v2.4/linux-2.4.18-ia64-020
226.bz2) on it  .

2. Now I have build the kernel (using make compressed) for ia64 processor
type generic.

3. I have copied vmlinuz.gz (using mcopy) to vfat mounted partition
(/boot/efi/efi/redhat) and made appropriate entries in elilo.conf. 

4. Now I have rebooted the system and tried to load the image using EFI
shell.

5. The kernel is not able to boot it stops executing after displaying
message "kernel bug at bootmem.c line:113!".

I have following doubts: -

1. Is it possible to build and run _stock_ kernel (not redhat patched
kernel) on hp zx6000 machine ? Do I need additional patches the stock kernel
2.4.18 + ia64 patch ?

PLEASE CC REPLY TO ME ALSO..

Thanks in advance..

Deepak Kumar Gupta
HCL Technologies Limited
NOIDA, UP
INDIA.

 
