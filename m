From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Tue, 07 Oct 2003 05:06:10 +0000
Subject: Re: current bk goes BUG on ia64 when dumping core; FIXED, PATCH
Message-Id: <marc-linux-ia64-106550321421301@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106533868423168@msgid-missing>
In-Reply-To: <marc-linux-ia64-106533868423168@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Andrew" = Andrew Morton <akpm@osdl.org> writes:

Andrew> Roland McGrath <roland@redhat.com> wrote:
>> > When running the latest LTP code, it dies in the new coredump
>> code.
>> 
>> This is what I predicted when I sent the second ia64 version of the
>> patch.  Please refer to that message for complete testing
>> instructions to verify the core format is correct (assuming it
>> doesn't crash any more with the new patch).  I've made another
>> cosmetic change to avoid using "vsyscall" in variable names, and
>> here is that version of the patch relative to the current 2.6 tree.


The new version doesn't BUG.  I couldn't find the message you were
referring to, Roland ... However, gdb understands the core dump; and
objdump shows a .auxv section that looks the right size etc.

Andrew> I am in Tokyo and am not able to test your patch.  Could
Andrew> someone please apply Roland's patch to current -bk, then run
Andrew> Linux Test Project (it BUGged in two seconds for me) and then
Andrew> send the patch to Linus fairly promptly?

And the patch, repeated from Roland McGrath's message.

Index: linux-2.5/include/asm-ia64/elf.h
=================================RCS file: /home/cvs/linux-2.5/include/asm-ia64/elf.h,v
retrieving revision 1.11
diff -u -b -p -r1.11 elf.h
--- linux-2.5/include/asm-ia64/elf.h 3 Oct 2003 22:45:47 -0000 1.11
+++ linux-2.5/include/asm-ia64/elf.h 6 Oct 2003 04:53:23 -0000
@@ -218,20 +218,23 @@ do {										\
 #define ELF_CORE_EXTRA_PHDRS		(GATE_EHDR->e_phnum)
 #define ELF_CORE_WRITE_EXTRA_PHDRS						\
 do {										\
-	const struct elf_phdr *const vsyscall_phdrs =			      \
+	const struct elf_phdr *const gate_phdrs =			      \
 		(const struct elf_phdr *) (GATE_ADDR + GATE_EHDR->e_phoff);   \
 	int i;									\
-	Elf32_Off ofs = 0;						      \
+	Elf64_Off ofs = 0;						      \
 	for (i = 0; i < GATE_EHDR->e_phnum; ++i) {				\
-		struct elf_phdr phdr = vsyscall_phdrs[i];		      \
+		struct elf_phdr phdr = gate_phdrs[i];			      \
 		if (phdr.p_type = PT_LOAD) {					\
-			BUG_ON(ofs != 0);				      \
-			ofs = phdr.p_offset = offset;				\
 			phdr.p_memsz = PAGE_ALIGN(phdr.p_memsz);	      \
 			phdr.p_filesz = phdr.p_memsz;			      \
+			if (ofs = 0) {					      \
+				ofs = phdr.p_offset = offset;		      \
 			offset += phdr.p_filesz;				\
 		}							      \
 		else							      \
+				phdr.p_offset = ofs;			      \
+		}							      \
+		else							      \
 			phdr.p_offset += ofs;					\
 		phdr.p_paddr = 0; /* match other core phdrs */			\
 		DUMP_WRITE(&phdr, sizeof(phdr));				\
@@ -239,13 +242,15 @@ do {										\
 } while (0)
 #define ELF_CORE_WRITE_EXTRA_DATA					\
 do {									\
-	const struct elf_phdr *const vsyscall_phdrs =			      \
+	const struct elf_phdr *const gate_phdrs =			      \
 		(const struct elf_phdr *) (GATE_ADDR + GATE_EHDR->e_phoff);   \
 	int i;								\
 	for (i = 0; i < GATE_EHDR->e_phnum; ++i) {			\
-		if (vsyscall_phdrs[i].p_type = PT_LOAD)		      \
-			DUMP_WRITE((void *) vsyscall_phdrs[i].p_vaddr,	      \
-				   PAGE_ALIGN(vsyscall_phdrs[i].p_memsz));    \
+		if (gate_phdrs[i].p_type = PT_LOAD) {			      \
+			DUMP_WRITE((void *) gate_phdrs[i].p_vaddr,	      \
+				   PAGE_ALIGN(gate_phdrs[i].p_memsz));	      \
+			break;						      \
+		}							      \
 	}								\
 } while (0)
 
-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

