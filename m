From: William Taber <wtaber@rational.com>
Date: Thu, 18 Jan 2001 15:47:07 +0000
Subject: Re: [Linux-ia64] PATCH:  Building on ia32
Message-Id: <marc-linux-ia64-105590693005075@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005061@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005061@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>
>But your patch breaks the lazy-execute bit scheme that IA-64 relies on to avoid
>cache flushing.  Your kernel will probably hang on any app that does dynamic
>code generation (e.g., such as due to nested C functions).
>
>You're probably better off implementing is_exec_access() on x86 as always
>returning 0.
>
>	--david

David,

Actually, I think the best solution is to move is_exec_access() and
is_write_access() out of asm-ia64/pgtable.h, and into some machine independent
header (perhaps mm.h ?), redefining the magic numbers 2 and 4 to be VM_WRITE
and VM_EXEC respectively.  This still leaves the question of who is 
responsible for changing all of the platform specific callers of 
handle_mm_fault to reflect the new semantics?

Will

+---------------------------------------------------------------------+
| Will Taber                                                          |
| Software Engineer, CMBU                 E-mail  wtaber@rational.com |
| Rational Software Corporation           Phone:  781-676-2436        |
| 20 Maguire Road, Lexington, Mass. 02421                             |
+---------------------------------------------------------------------+


