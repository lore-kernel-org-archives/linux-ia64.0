From: Peter Bergner <bergner@vnet.ibm.com>
Date: Thu, 24 Jan 2002 13:51:48 +0000
Subject: Re: [Linux-ia64] IA64 ELF header question...
Message-Id: <marc-linux-ia64-105590698805926@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805902@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805902@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Cary Coutant wrote:
> PA-RISC also uses function descriptors. On HP-UX, for both PA-RISC and
> IA-64, the e_entry field is the address of the code entry point itself,
> rather than the address of a function descriptor. Our dynamic loader
> initializes its own gp value, and when it's time for the dynamic loader
> to call the application's entry point, it knows what the gp value should
> be, so we don't need a function descriptor.

This looks also to be the case for Linux/IA64 (from what I gathered from
looking at the IA64 kernel and GLIBC source).  Changing our ABI to match
this doesn't look promising, as we're not the only OS using this ABI.
This means I'll need to modify the kernel to reloc our function
descriptor (FD)
entries.  The only problem is, I don't have enough information in
start_thread
to know whether I need to reloc the FD entries or not.  Seems like I'll
need
to place some code in fs/binfmt_elf.c to gather up the information
needed
to perform the reloc's in start_thread.

Note I don't really want to reloc the function descriptor entries, just
the values I copy out of the entries as I stuff them into my pt_regs
struct.

Peter

