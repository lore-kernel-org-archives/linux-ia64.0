From: Khalid Aziz <khalid.aziz@hp.com>
Date: Tue, 16 Nov 2004 03:46:49 +0000
Subject: Re: [Fastboot] [PATCH] kexec on ia64
Message-Id: <1100576808.2371.0.camel@minuet.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1100551268.26287.35.camel@lyra.fc.hp.com>
In-Reply-To: <1100551268.26287.35.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Another limitation I forgot to mention. I have not added support for
compressed kernel to kexec-tools yet. It is on my list of things to do
next.

--
Khalid

On Mon, 2004-11-15 at 13:32, Khalid Aziz wrote:
> I have been able to get kexec working on ia64. I am attaching the kernel
> patch and kexec-tools patch. For the kernel patch, start with 2.6.8
> kernel from kernel.org, apply ia64 patch
> <http://www.kernel.org/pub/linux/kernel/ports/ia64/v2.6/linux-2.6.8-ia64-040901.diff.bz2>, apply Eric' 2.6.8.1-kexec3 patch <http://www.xmission.com/~ebiederm/files/kexec/2.6.8.1-kexec3> and apply attached 2.6.8.1-kexec3-ia64.diff patch. For kexec-tools, apply attached kexec-tools-1.98-ia64.diff patch to Eric's kexec-tools 1.98 sources <http://www.xmission.com/~ebiederm/files/kexec/kexec-tools-1.98.tgz>.
> 
> At this point, I have done minimal testing. Here is what I know does not
> work currently:
> 
> 1. No support for initrd for kexec'd kernel
> 
> 2. No support for new kernel parameters for kexec'd kernel.
> 
> 3. If a kernel is booted up with "mem=" or "max_addr=" to restrict the
> amount of memory, a kernel kexec'd from this kernel will only see the
> same amount of memory as this one. This is not only due to the new
> kernel being kexec'd with the same parameter, but also becuase the EFI
> memory map as passed to the kernel by ELILO gets trimmed very early on
> by the kernel. I have tried adding code to save the memory map early on
> and then pass this saved memory map to kexec'd kernel, but apparently I
> still am not saving it early enough. I wait until bootmem allocator has
> been initailized so I can allocate memory to save unmolested EFI memory
> map in. In the process of initializing bootmem allocator, kernel calls
> efi-Memory_map_walk() which in turn trims the memory map. I am looking
> into allocating memory out of the EFI memory map before the first
> efi_mem_map_walk() happens, so I can save pristine EFI memmap for use
> later by kexec.
> 
> Here is what I have not tested yet:
> 
> 1. I am not sure if  ACPI subsystem is happy in kexec'd kernel. I have
> not seen any problems, but I have not tested it enough either.
> 
> 2. Stability of kexec'd kernel over long term. It ran fine for an hour
> not doing much :)
> 
> Here is what I am working on next:
> 
> 1. Save EFI memory map before it is trimmed.
> 
> 2. Fix up /proc/iomem on ia64 so we can enable validating memory range
> in kexec tools.
> 
> 3. Add a /proc interface to enable reboots on panic and INIT (and
> possibly MCA) to be kexec reboots.
> 
> 4. Add initrd support.
> 
> Any feedback on these patches is welcome. Any patch to fix problems in
> these patches is very much appreciated :)
-- 
Khalid Aziz                                 Linux and Open Source Lab
(970)898-9214                                         Hewlett-Packard
khalid_aziz@hp.com                                   Fort Collins, CO

