From: Jay Lan <jlan@sgi.com>
Date: Tue, 14 Nov 2006 00:57:08 +0000
Subject: 'kexec -l' problem at IA64 SN
Message-Id: <45591464.5050206@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I finally got time to work on 'kexec -l' problem at SGI box.
The 'kexec -l' always failed on "Invalid memory segment".
I am using these patches:
  kexec-tools-1.101-kdump10.patch
  kexec-tools-1.101-ia64-kdump10-efi-boot.patch
  clone-ia64_boot_param-kdump10.patch
  fix-paddr-vmcore-ELF
  kexec-ia64-reset-vga (a special workaround from Nanhai to
                        handle vga i/o issue)
Note that 'kexec -p' worked fine for me.

It would try to add memory segment 0x4000000 - 0x4997fff,
but failed in valid_memory_range() check.

It was the first segment it tried to load.

The kexec_info struct showed:
(gdb) p *(struct kexec_info *)0x607fffffffa0b338
$2 = {segment = 0x0, nr_segments = 0, entry = 0x0, rhdr = {ei_class = 0,
    ei_data = 0, e_type = 0, e_machine = 0, e_version = 0, e_flags = 0,
    e_phnum = 0, e_shnum = 0, e_shstrndx = 0, e_entry = 0, e_phoff = 0,
    e_shoff = 0, e_notenum = 0, e_phdr = 0x0, e_shdr = 0x0, e_note = 0x0,
    rel_addr = 0, rel_size = 0}, backup_start = 0, kexec_flags = 0}


and, the mem_phdr struct showed:
(gdb) p *(struct mem_phdr *) 0x6000000000014e20
$4 = {p_paddr = 67108864, p_vaddr = 11529215050363437056,
  p_filesz = 10000768, p_memsz = 10000768, p_offset = 65536,
  p_data = 0x2000000000338010 "\004\200", p_type = 1, p_flags = 7,
  p_align = 65536}
(gdb)

The 'base' variable in elf_exec_load() at the time of calling
add_segment() was 0.

Where did it go wrong? The phdr->p_paddr? The base? It was off
by 0x3000000000. It needs adjustment, but where in the code and
which value?

The 'kexec -p' worked fine.

Thanks,
 - jay



