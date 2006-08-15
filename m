From: Keshavamurthy Anil S <anil.s.keshavamurthy@intel.com>
Date: Tue, 15 Aug 2006 19:46:35 +0000
Subject: Re: IA64 Kexec-Kdump kernel patch
Message-Id: <20060815124634.A1065@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1155538073.2585.44.camel@linux-znh>
In-Reply-To: <1155538073.2585.44.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Aug 14, 2006 at 05:24:57PM -0400, Bob Montgomery wrote:
> On Mon, 2006-08-14 at 14:47 +0800, Zou Nan hai wrote:
> > This patch is the kexec-kdump patch re-based to 2.6.18-rc4 kernel.
> 
> Contrary to expectations, my experience with this patch on a 2.6.18-rc4
> kernel is that kexec -l, kexec -e is now working without my adding any
> delays to mptscsih, and the kexec -p, echo c >/proc/sysrq-trigger case
> hangs.
> 
> # cat /proc/cmdline
> BOOT_IMAGE=scsi0:/EFI/debian/boot/vmlinuz-2.6.18-rc4-bobm root=/dev/sda4
> raid=noautodetect crashkernel8M@256M panic=1 ro

Can you change crashkernelQ2M@256 and try
kexec -p, echo c > /proc/sysrq-trigger case.


