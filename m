From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Sat, 30 Apr 2016 08:20:55 +0000
Subject: Re: [PATCH 06/12] ARM: kexec: advertise location of bootable RAM
Message-Id: <20160430082055.GG19428@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
 <E1aviF4-0000jG-MO@rmk-PC.arm.linux.org.uk>
 <CAHB_GurHc1aVfzJATpNW5yf5s5KkF=t5s09FbWq3+9+ZX39KUg@mail.gmail.com>
 <20160429180024.GS19428@n2100.arm.linux.org.uk>
 <CAHB_GuqhPJ7J-MNbjxqeQnogW-J6=Bt2e1STKSG5kzJT+4PJpg@mail.gmail.com>
In-Reply-To: <CAHB_GuqhPJ7J-MNbjxqeQnogW-J6=Bt2e1STKSG5kzJT+4PJpg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pratyush Anand <panand@redhat.com>
Cc: linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>, Jonathan Corbet <corbet@lwn.net>, Ian Campbell <ijc+devicetree@hellion.org.uk>, kexec@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Rob Herring <robh+dt@kernel.org>, Eric Biederman <ebiederm@xmission.com>, Santosh Shilimkar <ssantosh@kernel.org>, Kumar Gala <galak@codeaurora.org>, Vivek Goyal <vgoyal@redhat.com>

On Sat, Apr 30, 2016 at 08:57:34AM +0530, Pratyush Anand wrote:
> On Fri, Apr 29, 2016 at 11:30 PM, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
> > On Fri, Apr 29, 2016 at 08:26:00PM +0530, Pratyush Anand wrote:
> >> Hi Russell,
> >>
> >> On Thu, Apr 28, 2016 at 2:58 PM, Russell King
> >> <rmk+kernel@arm.linux.org.uk> wrote:
> >> > Advertise the location of bootable RAM to kexec-tools.  kexec needs to
> >> > know where it can place the kernel in RAM, and so be executable when
> >> > the system needs to jump into it.
> >> >
> >> > Advertise these areas in /proc/iomem with a "System RAM (boot alias)"
> >> > tag.
> >> >
> >> > Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> >>
> >> Can you please also share git tree path of corresponding kexec-tools changes?
> >>
> >> Could it be a better idea (if things in user space become simpler)
> >> that in stead of patch 5 and 6, we pass arch_phys_to_idmap_offset to
> >> user space, and then user space manipulates existing "Crash kernel"
> >> and "System RAM" resources.
> >
> > Given that it's only _one_ platform right now, I don't think that
> > additional complexity is worth it.  It means that we have to invent
> 
> Probably, I could not communicate it well.  I was not trying  to have
> *additional* complexity. Wanted to see if things could be simpler
> rather. So this is what my understanding was:
> -- We create one patch to pass arch_phys_to_idmap_offset to user space
> (say in /sys/kernel/bootmem_idmap_offset)
> -- We do not use patch 5,6,11 and 12 of this series. Probably few more
> content of the series will go away.

Patches 11 and 12 don't go away with what you're suggesting.  Patches
11 and 12 are necessary to allow the boot-view addresses to be passed
into the kernel through kexec, and to allow kexec to find appropriate
memory resources.

For example, from patch 11:

@@ -48,7 +48,8 @@ static int kimage_alloc_init(struct kimage **rimage, unsigned
long entry,

-               if ((entry < crashk_res.start) || (entry > crashk_res.end))
+               if ((entry < phys_to_boot_phys(crashk_res.start)) ||
+                   (entry > phys_to_boot_phys(crashk_res.end)))

"entry" is limited to a 32-bit physical address as it is unsigned long,
and is the boot-view physical address.  crashk_res.start is the
running-view physical address.  Without this change, the rest will
always be true on Keystone 2.

@@ -229,8 +229,8 @@ int sanity_check_segment_list(struct kimage *image)
-                       if ((mstart < crashk_res.start) ||
-                           (mend > crashk_res.end))
+                       if ((mstart < phys_to_boot_phys(crashk_res.start)) ||
+                           (mend > phys_to_boot_phys(crashk_res.end)))

Same problem - mstart and mend are both 32-bit quantities.  The result
is the segment list validation always fails.

@@ -354,7 +354,7 @@ static struct page *kimage_alloc_normal_control_pages(struct kimage *image,
-               pfn   = page_to_pfn(pages);
+               pfn   = page_to_boot_pfn(pages);

The result without this change is that we allocate _all_ system memory
looking for a suitable page, never finding one because we never find
a page which matches.  Without a previous patch, killing many
processes and taking the system down.

@@ -480,7 +480,7 @@ static int kimage_add_entry(struct kimage *image, kimage_entry_t entry)
-               *image->entry = virt_to_phys(ind_page) | IND_INDIRECTION;
+               *image->entry = virt_to_boot_phys(ind_page) | IND_INDIRECTION;

The physical address would end up being truncated to 32-bits, but
would actually be larger than 4GiB.  So, *image->entry would point
at the incorrect address, and kexec would fail.

@@ -535,13 +535,13 @@ void kimage_terminate(struct kimage *image)
 #define for_each_kimage_entry(image, ptr, entry) \
        for (ptr = &image->head; (entry = *ptr) && !(entry & IND_DONE); \
                ptr = (entry & IND_INDIRECTION) ? \
-                       phys_to_virt((entry & PAGE_MASK)) : ptr + 1)
+                       boot_phys_to_virt((entry & PAGE_MASK)) : ptr + 1)

"entry" is truncated to 32-bit, and so this passes an invalid
physical address which is not part of the lowmem mapping to
phys_to_virt().  The resulting virtual address is undefined.

-       page = pfn_to_page(entry >> PAGE_SHIFT);
+       page = boot_pfn_to_page(entry >> PAGE_SHIFT);

Same, except the resulting struct page pointer is undefined.

... and so it goes on.

The only patches which get replaced are patches 5 and 6 with a new
userspace API.

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
