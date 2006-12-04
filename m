From: "Akiyama, Nobuyuki" <akiyama.nobuyuk@jp.fujitsu.com>
Date: Mon, 04 Dec 2006 02:05:10 +0000
Subject: Re: [Fastboot] IA64: kexec seg fault at xrealloc
Message-Id: <20061204110510.fde8bcdb.akiyama.nobuyuk@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jay,

The attacked patch fixes the problem.
Please try.

diff -Nurp kexec-tools-1.101.org/kexec/arch/ia64/crashdump-ia64.c kexec-tools-1.101/kexec/arch/ia64/crashdump-ia64.c
--- kexec-tools-1.101.org/kexec/arch/ia64/crashdump-ia64.c	2006-11-09 19:40:52.000000000 +0900
+++ kexec-tools-1.101/kexec/arch/ia64/crashdump-ia64.c	2006-11-13 19:17:15.000000000 +0900
@@ -316,9 +316,13 @@ int load_crashdump_segments(struct kexec
 	int nr_ranges;
 	size_t size;
 	void *tmp;
+	long int nr_cpus = 0;
+	if ((nr_cpus = sysconf(_SC_NPROCESSORS_CONF)) < 0)
+		return -1;
 	if (info->kexec_flags & KEXEC_ON_CRASH ) {
 		if (get_crash_memory_ranges(&mem_range, &nr_ranges) = 0) {
 			size =  sizeof(Elf64_Ehdr) +
+				(nr_cpus + 1) * sizeof(Elf64_Phdr) +
 				(nr_ranges + 1) * sizeof(Elf64_Phdr);
 			size = (size + EFI_PAGE_SIZE - 1) & ~(EFI_PAGE_SIZE - 1);
 			tmp = xmalloc(size);

Thanks,
Akiyama, Nobuyuki


On Fri, 01 Dec 2006 15:55:27 -0800
Jay Lan <jlan@sgi.com> wrote:

> The kexec seg faulted when i ran test at an 56p SN machine.
> It was successful on a 2p SN.
> 
> 
> (gdb) bt
> #0  0x200000000016a900 in _int_realloc () from /lib/libc.so.6.1
> #1  0x200000000016e020 in realloc () from /lib/libc.so.6.1
> #2  0x40000000000020c0 in xrealloc (ptr=0x600000000002ada0, size0)
>     at kexec/kexec.c:70
> #3  0x40000000000042a0 in add_segment (info=0x60000ffffe2c3718,
>     buf=0x600000000002ae30, bufsz288, base 6963621888, memsz384)
>     at kexec/kexec.c:310
> #4  0x40000000000047f0 in add_buffer (info=0x60000ffffe2c3718,
>     buf=0x600000000002ae30, bufsz288, memsz384, buf_align@96,
>     buf_min=0, buf_max446744073709551615, buf_end=-1) at
> kexec/kexec.c:345
> #5  0x400000000001aa20 in load_crashdump_segments (info=0x60000ffffe2c3718,
>     ehdr=0x60000ffffe2c3578, max_addr446744073709551615, min_base=0,
>     cmdline=0x60000ffffe2c35e8) at kexec/arch/ia64/crashdump-ia64.c:328
> #6  0x4000000000016970 in elf_ia64_load (argc=6, argv=0x60000ffffe2c3af8,
>     buf=0x2000000000324010 "\177ELF\002\001\001", len939392,
>     info=0x60000ffffe2c3718) at kexec/arch/ia64/kexec-elf-ia64.c:203
> #7  0x4000000000006a00 in my_load (type=0x0, fileind=5, argc=6,
>     argv=0x60000ffffe2c3af8, kexec_flags=1) at kexec/kexec.c:617
> #8  0x4000000000008220 in main (argc=6, argv=0x60000ffffe2c3af8)
>     at kexec/kexec.c:859
> (gdb)
> 
> The add_segment() contains code as below:
> 
> add_segment()
> {
>         ...
>         last = base + memsz -1;
>         if (!valid_memory_range(base, last)) {
>                 die("Invalid memory segment %p - %p\n",
>                         (void *)base, (void *)last);
>         }
> 
>         size = (info->nr_segments + 1) * sizeof(info->segment[0]);
>         info->segment = xrealloc(info->segment, size); <=== seg fault
>         info->segment[info->nr_segments].buf   = buf;
>         info->segment[info->nr_segments].bufsz = bufsz;
>         info->segment[info->nr_segments].mem   = (void *)base;
>         info->segment[info->nr_segments].memsz = memsz;
> 
>         info->nr_segments++;
>         ...
> }
> 
> The seg fault happened on nr_segment=4. At the end of nr_segment=3
> info->segment was set to 2ada0 in the statement
>         info->segment = xrealloc(info->segment, size);
> And the subsequent call to xrealloc() on nr_segment=4, it died.
> 
> On the 2p machine that was successful, the info->segment was set to
> 29310 at the end of nr_segment=3. It went all the way to 30b10 at
> the end of 9th segment. So, the value 2ada0 seems still in the bound.
> 
> Can anyone more familiar with xrealloc and kexec tell me what might
> cause the seg fault?
> 
> Thanks,
>  - jay
> _______________________________________________
> fastboot mailing list
> fastboot@lists.osdl.org
> https://lists.osdl.org/mailman/listinfo/fastboot
> 


