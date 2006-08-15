From: Bob Montgomery <bob.montgomery@hp.com>
Date: Tue, 15 Aug 2006 19:31:09 +0000
Subject: Re: IA64 Kexec-Kdump kernel patch
Message-Id: <1155670269.26951.215.camel@amd.troyhebe>
List-Id: <linux-ia64.vger.kernel.org>
References: <1155538073.2585.44.camel@linux-znh>
In-Reply-To: <1155538073.2585.44.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2006-08-15 at 12:46 -0700, Keshavamurthy Anil S wrote:
> On Mon, Aug 14, 2006 at 05:24:57PM -0400, Bob Montgomery wrote:
> > On Mon, 2006-08-14 at 14:47 +0800, Zou Nan hai wrote:
> > > This patch is the kexec-kdump patch re-based to 2.6.18-rc4 kernel.
> > 
> > Contrary to expectations, my experience with this patch on a 2.6.18-rc4
> > kernel is that kexec -l, kexec -e is now working without my adding any
> > delays to mptscsih, and the kexec -p, echo c >/proc/sysrq-trigger case
> > hangs.
> > 
> > # cat /proc/cmdline
> > BOOT_IMAGE=scsi0:/EFI/debian/boot/vmlinuz-2.6.18-rc4-bobm root=/dev/sda4
> > raid=noautodetect crashkernel8M@256M panic=1 ro
> 
> Can you change crashkernelQ2M@256 and try
> kexec -p, echo c > /proc/sysrq-trigger case.

04a40000-3f5e3fff : System RAM
  10000000-2fffffff : Crash kernel

bobm@urlp2:~$ cat /proc/cmdline
root=/dev/sda4 crashkernelQ2M@256M panic=1 ro

# kexec -p vmlinux.strip --append="root=/dev/sda4 maxcpus=1 panic=1
irqpoll ro"

# echo c >/proc/sysrq-trigger

Still hangs with no indication on the console after my printk("bye\n")
just before the br.call at the end of machine_kexec.

Bob M.

