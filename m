From: gowda_avinash@emc.com
Date: Thu, 02 Sep 2004 11:00:03 +0000
Subject: compiling 2.4.21 vanilla kernel
Message-Id: <50C05B7AA7D6924FB5E384EF14BC647B0DB8C7@inba1mx2.corp.emc.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

All: 
I have been trying to boot of a vanilla kernel (2.4.21) which I compiled.
When I boot of my new kernel I get this message 

Kernel Panic: VFS: Unable to mount root fs on unknown-block(0,0)

This looks like a trivial booking keeping elilo.conf issue, but I am not
able to figure out what the problem is. 

This is a snapshot of my elilo.conf


<snip>

prompt
timeout0
default=2.4.21

image=vmlinuz-2.4.21
        label=2.4.21
        initrd=initrd-2.4.21.img
        read-only
        append="root=LABEL=/"

image=vmlinuz-2.4.21-15.0.4.EL
        label=hack
        initrd=initrd-2.4.21-15.0.4.EL.img
        read-only
        append="root=LABEL=/"

image=vmlinuz-2.4.21-15.0.4.EL
        label=2.4.21-15.0.4.EL
        initrd=initrd-2.4.21-15.0.4.EL.img
        read-only
        append="root=LABEL=/"

<snip>

I am not able to boot off only the first one in the list. 

This is how I am compiling the kernel. 
make mrproper
make clean
make menuconfig
make dep
make vmlinux 
I copied the vmlinux to /boot/efi/efi/Redhat (where all my images are) and 
Lastly did the mkinitrd. 

I am wondering where I am going wrong. 



TIA

avinash
