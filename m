From: Keith Owens <kaos@sgi.com>
Date: Sat, 28 Feb 2004 10:00:54 +0000
Subject: Re: Oops in pdflush
Message-Id: <15704.1077962454@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 28 Feb 2004 20:45:38 +1100, 
Keith Owens <kaos@sgi.com> wrote:
>This is what the ia64 stack for a pdflush worker thread looks like now.
>It has used 560 bytes of stack from creation to sleep.
>
>0xe00000003db08000       16        1  0    2   S  0xe00000003db08570  pdflush
>0xa0000001000830f0 schedule+0xf30
>0xa0000001000dab70 __pdflush+0x230
>0xa0000001000daf00 pdflush+0x20
>0xa000000100016bc0 kernel_thread+0x100
>0xa0000001000db250 pdflush_master+0xb0
>0xa000000100016bc0 kernel_thread+0x100
>0xa000000100650670 pdflush_init+0x30
>0xa000000100641100 do_initcalls+0xc0
>0xa000000100009300 init+0xe0
>0xa000000100016bc0 kernel_thread+0x100
>0xa000000100009090 rest_init+0x30
>0xa000000100640f80 start_kernel+0x460
>0xa0000001000085a0 _start+0x280

Without DavidM's patch to add ia64_invoke_kernel_thread_helper, pdflush
starts with 560 bytes of stack and 744 bytes of rbs.  With
ia64_invoke_kernel_thread_helper, that reduces to 554 bytes of stack
and 272 bytes of rbs.  Backtrace with ia64_invoke_kernel_thread_helper.

0xa000000100083290 schedule+0xf30
0xa0000001000dad10 __pdflush+0x230
0xa0000001000db0a0 pdflush+0x20
0xa000000100016d70 kernel_thread_helper+0xd0
0xa000000100009040 ia64_invoke_kernel_thread_helper+0x20

We need both ia64_invoke_kernel_thread_helper and my patch to pdflush.
Until all architectures have a kernel_thread helper, nested calls to
kernel_thread will chew up stack.

