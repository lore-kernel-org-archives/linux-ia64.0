From: "Mike Fox" <mfox@annapmicro.com>
Date: Wed, 09 Apr 2003 05:36:33 +0000
Subject: RE: [Linux-ia64] mmap crashes system after mapping PCI device into user space and reading and writin
Message-Id: <marc-linux-ia64-105590723705445@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705441@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705441@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ok I have some more info. The crash only happens after I do a write to my
PCI controller. I map the PCI controller into user space and I can read and
write a scratch register ok. I can also read other initialized registers to
confirm I am reading my PCI controller. I can do many reads, but after some
number of writes the system goes down. I went ahead and updated the kernel
to 2.4.20 with the latest patches. Any thoughts or a push in the right
direction are very much appreciated.

My mmap call in user space looks something like this:

    pRegRegionMappedAddr = (DWORD*)mmap( 0, 
                                         WSII_REG_SPACE_SIZE_BYTES,
                                         PROT_WRITE | PROT_READ,
                                         MAP_SHARED,
                                         DriverHandle,
                                         0 );

In the driver I am basically doing this in my mmap entry point:

  vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
  vma->vm_flags |= VM_IO;

  /*
   * this maps the physical memory to the user
   */
  if (remap_page_range(vma->vm_start, offset, vma->vm_end-vma->vm_start,
                            vma->vm_page_prot))
  {
    return -EAGAIN;
  }

Thanks,
Mike.



-----Original Message-----
From: linux-ia64-admin@linuxia64.org [mailto:linux-ia64-admin@linuxia64.org]
On Behalf Of Grant Grundler
Sent: Tuesday, April 08, 2003 8:43 PM
To: Mike Fox
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] mmap crashes system after mapping PCI device into
user space and reading and writing.

On Tue, Apr 08, 2003 at 05:59:56PM -0400, Mike Fox wrote:
...
> Has anyone tried using mmap to remap PCI device memory into user space?  I
> have seen the following problem:  If I do the mmap, it returns
successfully,
> and I can indeed access the device memory.  Unfortunately, the system will
> hang within about a minute after doing so.
...

David Mosberger passed on a very short program who's essence is:
  mem = mmap (NULL, page_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd,
offset);
  if (mem == MAP_FAILED)
  {
    perror ("memmap");
    exit (-1);
  }

This works on the HP ZX1 platforms with 2.4.20+patches kernel.

Be warned, it's *very* easy to crash a machine when using /dev/mem
and scribbling in misc parts of IO space. The symptom will typically
be an MCA (see "errdump MCA" output from EFI to get the xip).

grant

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


