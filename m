From: Jes Sorensen <jes@wildopensource.com>
Date: Fri, 05 Aug 2005 14:12:58 +0000
Subject: Re: 2.6.13-rc5 does not boot on Tiger4
Message-Id: <yq0irykfp5h.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <jeoe8fyrfb.fsf@sykes.suse.de>
In-Reply-To: <jeoe8fyrfb.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:

Tony> So it looks like your problem is
Tony> CONFIG_IA64_UNCACHED_ALLOCATOR=y
>>  Impossible, thats my code! It can't be broken ;-)
>> 
>> Anyone who have tried this on an ZX1 box? Otherwise I'll try it out
>> on my 2600 tomorrow and see if I can reproduce it.

Tony> It may help to know that on the tiger, efi_memmap_walk_uc
Tony> decides that this efi_memory_desc_t entry is fair game:

Tony>  type = 11 (EFI_MEMORY_MAPPED_IO) phys_addr = 0xfe000000
Tony> num_pages = 0x1000 attribute = 0x1

Details, details ;-)

I think this patch should take care of it.

Cheers,
Jes

Only grab uncached pages from the boot services data section to avoid
grabbing memory mapped IO regions by mistake.

Signed-off-by: Jes Sorensen <jes@trained-monkey.org>

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -431,7 +431,8 @@ efi_memmap_walk_uc (efi_freemem_callback
 
 	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
 		md = p;
-		if (md->attribute = EFI_MEMORY_UC) {
+		if (md->type = EFI_BOOT_SERVICES_DATA &&
+		    md->attribute = EFI_MEMORY_UC) {
 			start = PAGE_ALIGN(md->phys_addr);
 			end = PAGE_ALIGN((md->phys_addr+(md->num_pages << EFI_PAGE_SHIFT)) & PAGE_MASK);
 			if ((*callback)(start, end, NULL) < 0)
