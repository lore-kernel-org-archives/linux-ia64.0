From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Wed, 01 Aug 2001 20:02:18 +0000
Subject: RE: [Linux-ia64] settings AR.k0 to ia64_iobase is wrong?
Message-Id: <marc-linux-ia64-105590693005980@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005964@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005964@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

The setup code is not setting the virtual address in the ar.k0. Here is a
patch to set the virtual address.

Thanks,
Asit

--- linux-2.4.7/arch/ia64/kernel/setup.c        Tue Jul 31 14:57:10 2001
+++ linux/arch/ia64/kernel/setup.c      Wed Aug  1 14:26:44 2001
@@ -314,15 +314,15 @@
         *  AR.KR0 if no appropriate entry is found in the memory map.
         */
        ia64_iobase = efi_get_iobase();
-       if (ia64_iobase)
-               /* set AR.KR0 since this is all we use it for anyway */
-               ia64_set_kr(IA64_KR_IO_BASE, ia64_iobase);
-       else {
+       if (!ia64_iobase) {
                ia64_iobase = ia64_get_kr(IA64_KR_IO_BASE);
                printk("No I/O port range found in EFI memory map, falling
back to AR.KR0\n");
                printk("I/O port base = 0x%lx\n", ia64_iobase);
        }
        ia64_iobase = __IA64_UNCACHED_OFFSET | (ia64_iobase & ~PAGE_OFFSET);
+
+       /* set AR.KR0 since this is all we use it for anyway */
+       ia64_set_kr(IA64_KR_IO_BASE, ia64_iobase);
 
 #ifdef CONFIG_SMP
        cpu_physical_id(0) = hard_smp_processor_id();


> -----Original Message-----
> From: David Mosberger [mailto:davidm@hpl.hp.com]
> Sent: Tuesday, July 31, 2001 12:23 PM
> To: dong@rose.hp.com
> Cc: nomura@hpc.bs1.fc.nec.co.jp; linux-ia64@linuxia64.org;
> mani.ayyar@intel.com
> Subject: RE: [Linux-ia64] settings AR.k0 to ia64_iobase is wrong?
> 
> 
> >>>>> On Tue, 31 Jul 2001 11:57:09 -0700, "Dong Wei" 
> <dong_wei@hp.com> said:
> 
>   Dong> AR.k0 contains the virtual address that SAL uses for the IO
>   Dong> Port Base.  The SAL spec asks the OSes not to change this
>   Dong> value until the IVAs are taken over. The reason for this is
>   Dong> that some implementation of SAL contains the x86 BIOS code.
> 
> Yup.  We don't violate this assumption as we switch the IVA long
> before we touch AR.k0.
> 
> 	--david
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


