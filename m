From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 09 Apr 2002 04:46:39 +0000
Subject: Re: [Linux-ia64] epilogue count exceeds number of nested prologues
Message-Id: <marc-linux-ia64-105590701905421@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905403@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905403@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Randolph,

>>>>> On Sun, 7 Apr 2002 17:17:14 -0700, Randolph Chung <randolph@tausq.org> said:

  Randolph> Hi all,
  Randolph> While trying to compile mozilla with libffi, the configure phase
  Randolph> dies with a message:

  Randolph> Error: Epilogue count of 4294967296 exceeds number of nested prologues
  Randolph> (0)

  Randolph> I see that this message comes from a patch submitted by David in
  Randolph> February. Is libffi broken? What is needed to fix it?


  Randolph> The offending assembly code is attached. it's the ".restore sp"
  Randolph> near the end that is triggering the error.

I'm unable to reproduce this.  If I'm understanding you right, the
problem occurred during the configure phase of mozilla (not libffi).
I just rebuilt Mozilla from the current CVS tree with gcc3.1
pre-release and the current CVS binutils.  It built just fine and the
resulting binary seems to work flawlessly.

From the assembly code you provided, it looks as if conftest.c tried
to call FFI_STATIC_CLOSURE() from within a function, which can't
possibly work.

Can you provide a more precise pointer where this conftest.c is being
generated?

Thanks,

	--david

  Randolph> .file	"conftest.i"
  Randolph> .pred.safe_across_calls p1-p5,p16-p63
  Randolph> .text
  Randolph> .align 16
  Randolph> .global main#
  Randolph> .proc main#
  Randolph> main:
  Randolph> .prologue 2, 2
  Randolph> .vframe r2
  Randolph> mov r2 = r12
  Randolph> .body
  Randolph> ;;
  Randolph> #APP
  Randolph> .data
  Randolph> .align 8
  Randolph> 1:   data8 @fptr(ffi_closure_UNIX)
  Randolph> data8 1b
  Randolph> data8 0
  Randolph> data8 bar
  Randolph> data8 @fptr(baz)
  Randolph> data8 quux
  Randolph> .text
  Randolph> .global foo
  Randolph> .proc foo
  Randolph> foo:
  Randolph> addl r16 = @ltoff(1b), gp;;
  Randolph> ld8  gp = [r16];;
  Randolph> ld8  r17 = [gp];;
  Randolph> ld8  r19 = [r17],8;
  Randolph> adds r18 = 16,gp;;
  Randolph> ld8  r20 = [r17];;
  Randolph> st8  [r18]=r20;
  Randolph> mov b6 = r19
  Randolph> br.cond.sptk.many b6
  Randolph> .endp

  Randolph> #NO_APP
  Randolph> ;;
  Randolph> mov r8 = r0
  Randolph> .restore sp
  Randolph> mov r12 = r2
  Randolph> br.ret.sptk.many b0
  Randolph> .endp main#
  Randolph> .ident	"GCC: (GNU) 3.0.4"


  Randolph> _______________________________________________
  Randolph> Linux-IA64 mailing list
  Randolph> Linux-IA64@linuxia64.org
  Randolph> http://lists.linuxia64.org/lists/listinfo/linux-ia64

