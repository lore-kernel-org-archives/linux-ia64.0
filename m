From: Bill Nottingham <notting@redhat.com>
Date: Fri, 05 Dec 2003 02:43:20 +0000
Subject: Re: can't boot 2.6.0-test11
Message-Id: <marc-linux-ia64-107059253021175@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107057525104512@msgid-missing>
In-Reply-To: <marc-linux-ia64-107057525104512@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony (tony.luck@intel.com) said: 
> What does:
> 	# objdump -fp vmlinux
> say?

foo:     file format elf64-ia64-little
architecture: ia64-elf64, flags 0x00000112:
EXEC_P, HAS_SYMS, D_PAGED
start address 0x0000000004007f20
private flags = LE, CONS_GP, ABI64

Program Header:
    LOAD off    0x0000000000010000 vaddr 0xa000000100000000 paddr 0x0000000004000000 align 2**16
         filesz 0x00000000005a0c00 memsz 0x00000000005a0c00 flags rwx
    LOAD off    0x00000000005c0000 vaddr 0xffffffffffff0000 paddr 0x00000000045b0000 align 2**16
         filesz 0x00000000000084a8 memsz 0x00000000000084a8 flags rw-
    LOAD off    0x00000000005d0000 vaddr 0xa0000001005c0000 paddr 0x00000000045c0000 align 2**16
         filesz 0x00000000000a3004 memsz 0x0000000000131e48 flags rw-
0x70000001 off    0x00000000004c8568 vaddr 0xa0000001004b8568 paddr 0x00000000044b8568 align 2**3
         filesz 0x0000000000029898 memsz 0x0000000000029898 flags r--

> What version of elilo are you running? (Run "elilo -v" from the EFI prompt, I think).

3.4.

Bill
