From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 05 Feb 2010 15:32:53 +0000
Subject: binfmt_elf32 / compat_binfmt_elf.c
Message-Id: <20100205153253.GA24644@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It looks like IA64 still has it's own binfmt_elf32.c instead of using
the generic fs/compat_binfmt_elf.c which is used by other architectures
that have the regset infrastucture.  Any good reason for skipping that
part of the conversion?
