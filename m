From: Simon Horman <horms@verge.net.au>
Date: Fri, 12 Sep 2008 23:35:02 +0000
Subject: Re: [PATCH]IA64: do not include uncached memory to vmcore
Message-Id: <20080912233500.GF3832@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <48CACCBA.9030905@sgi.com>
In-Reply-To: <48CACCBA.9030905@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jay Lan <jlan@sgi.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, kexec@lists.infradead.org

On Fri, Sep 12, 2008 at 01:10:34PM -0700, Jay Lan wrote:
> Currently a memory segment in memory map with attribute of EFI_MEMORY_UC
> is denoted as "System RAM" in /proc/iomem, while memory of attribute
> (EFI_MEMORY_WB|EFI_MEMORY_UC) is also labeled the same.
> 
> The kexec utility then includes uncached memory as part of vmcore.
> The kdump kernel may MCA when it tries to save the vmcore to a disk.
> A normal "cached" access can cause MCAs.
> 
> Since kexec assembled memory ranges with memory tagged as "System RAM",
> the uncached memory will be excluded if it is labeled differently.
> 
> Simon, since only IA64 will create "Uncached RAM" label, i do not
> make changes to other arch.
> 
> Our HP machine in the lab is dead. I am sorry that i can not test
> against other IA64 systems (than SGI's). Feedback is very much
> appreciated.
> 
> The corresponding kernel patch is needed to test this kexec patch:
> http://marc.info/?l=linux-ia64&m2122791230130&w=2
> This patch without the kernel patch will have no effect and do no
> harm.

Hi Jay,

both of these patches seem reasonable to me, especially from a kexec point
of view. I will try and test them on an HP RX2620 and Intel Tiger 4 and
get back to you shortly.

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

