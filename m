From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 28 Jan 2002 21:15:16 +0000
Subject: Re: [Linux-ia64] Offsets from C struct into assembler
Message-Id: <marc-linux-ia64-105590698805945@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805940@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805940@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 29 Jan 2002 07:59:43 +1100, Keith Owens <kaos@ocs.com.au> said:

  Keith> On Mon, 28 Jan 2002 08:11:23 -0700, n0ano@indstorage.com
  Keith> wrote:
  >> Or you can check out how the IA64 Linux kernel does this.  The
  >> file `arch/ia64/tools/printoffsets.c' is a program that is
  >> compiled and, when run, generates the file `include
  >> asm-ia64/offsets.h' which is an ASM include file containing
  >> structure offsets.

  Keith> That tool is disappearing in 2.5 kernels.  All architectures
  Keith> will use the same method for generating asm offsets, the one
  Keith> I included in my previous mail.

As of v2.5.3-pre5 I don't see any sign of your new kernel build
environment being part of Linus' tree.  Perhaps it will be accepted
some day, but until that happens, the scheme described by Don is the
correct one.

	--david

