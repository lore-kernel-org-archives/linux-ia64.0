From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Wed, 26 Apr 2000 05:29:56 +0000
Subject: RE: [Linux-ia64] new kernel diff (relative to 2.3.99-pre5)
Message-Id: <marc-linux-ia64-105590678205045@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205032@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205032@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The kernel binary that you are trying to boot is seeming like corrupted.
esrly_printk will  not help as eli does not even seem to have passed the
control to kernel. 

> -----Original Message-----
> From: Johannes Erdfelt [mailto:jerdfelt@valinux.com]
> Sent: Tuesday, April 25, 2000 7:19 PM
> To: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] new kernel diff (relative to 2.3.99-pre5)
> 
> 
> On Tue, Apr 25, 2000, Jesse Barnes <jbarnes@sgi.com> wrote:
> > I applied this patch to a stock 2.3.99pre5 kernel and 
> compiled it with
> > the 3/23 toolchain snapshot + patches and SMP turned on.  
> The compile
> > went ok under a 2.3.51 up kernel, but when I try to boot I get the
> > message below and it hangs.  I thought I remembered someone 
> else having
> > this problem, but I couldn't find it in my mail archives.  
> Is there a
> > simple solution?  I'm running a 2p Lion box with A3 
> processors & 2 GB of
> > RAM.
> > 
> > fs0:\> eli vmlinux-2.3.99pre5smp root=/dev/sda2
> > Booting `vmlinux-2.3.99pre5smp' acpi_get_vectors
> > origin = 000000007FCDEE88
> > bus = 0
> > num_vector = B
> > bus = 1
> > num_vector = 9
> > bus = 2
> > num_vector = C
> > bus = 3
> > num_vector = C
> > bus = 4
> > num_vector = 8
> > bus = 5
> > num_vector = 8
> > bus = 6
> > num_vector = 8
> > unable to find _SB_.PCI7
> > Terminating boot services
> 
> This usually means that the kernel failed booting somehow.
> 
> There was a problem with one firmware version which didn't 
> setup the ACPI
> tables correctly which caused a problem.
> 
> You may want to try turning on early printk support. Don't 
> forget to set
> the video mode to 80x50 before running eli.
> 
> Then you'll see where it failed.
> 
> JE
> 
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 



