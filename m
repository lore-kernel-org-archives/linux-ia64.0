From: Andrew Morton <akpm@osdl.org>
Date: Sun, 05 Oct 2003 07:38:41 +0000
Subject: Re: current bk goes BUG on ia64 when dumping core
Message-Id: <marc-linux-ia64-106533955223557@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106533868423168@msgid-missing>
In-Reply-To: <marc-linux-ia64-106533868423168@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
>
>  kernel BUG at fs/binfmt_elf.c:1366!

This is inside the ELF_CORE_WRITE_EXTRA_PHDRS macro btw.
