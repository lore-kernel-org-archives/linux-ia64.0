From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Thu, 17 Jan 2002 18:41:33 +0000
Subject: Re: [Linux-ia64] Interactive installation with PXE booting
Message-Id: <marc-linux-ia64-105590698805873@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805871@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805871@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christopher,

On Thu, Jan 17, 2002 at 11:20:01AM -0700, Christopher D. Maestas wrote:
> Has anyone been able to write an elilo.conf that allows for an interactive
> network installation?  For example in pxelinux.cfg/default I can do:
> ---
> label vgainteractiverh72
>         kernel vmlinuz.rh72
>         append vga=extended root=/dev/ram0 initrd=initrd.img.rh72 console=tty0
> ---

Your problem has nothing to do with the fact that binaries are coming from
the network.

> 
> I tried in elilo.conf:
> ---
> prompt
> timeoutP
> default=localdisk
> verbose=5
> 
> image=vmlinuz.rh72-ia64
>         label=vgainteractiveia64
>         read-only
>         append = "vga=extended console=tty0"
> ---
> 
> And them type in vgainteractiveia64 when prompted, but the kernel panics because
> I didn't append a root option.  I've tried root=/dev/ram0 and that doesn't
> work either.
> 
The kernel needs two things to boot from a filesystem. First it needs to have
the device driver to access the disk controller. Second it needs to know
which partition the root filesystem is in. The problem you're seing comes
from the fact that your kernel does not have the valid device driver, most likely
the SCSI controller, builtin. This is common with kernels from distributions. 
The device driver is dynamically loaded in the kernel via a kernel module
which is stored into the initial ramdisk. So your problem is that you did not
indicate a initrd= option in your elilo.conf. Something like this will do:

image=vmlinuz.rh72-ia64
        label=vgainteractiveia64
        initrd=initrd.rh72
	append = "vga=extended console=tty0"


-- 
-Stephane

