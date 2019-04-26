From: Adam Richter <adamrichter4@gmail.com>
Date: Fri, 26 Apr 2019 21:12:05 +0000
Subject: Re: [Untested patch] Suspected null pointer dereference in ftrace_make_nop() for ia64
Message-Id: <CAGn-TgiVjo_Ko1YXoJJEWNUtcKpAFmt6TwYv1-C_TaeU_nju=A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAGn-Tgg9qOoFNKKrbK1=XQEKj8wwD26NWY+1G4cDHRySsJWcYQ@mail.gmail.com>
In-Reply-To: <CAGn-Tgg9qOoFNKKrbK1=XQEKj8wwD26NWY+1G4cDHRySsJWcYQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, again.

Please disregard this patch, which I submitted a few minutes ago.  I
somehow overlooked the fact that ftrace_make_nop() passes do_check=0
to trace_modifiy_code.  I am sorry for any distraction and time waste
that my submission of that patch has caused.

Adam Richter

On Fri, Apr 26, 2019 at 8:51 PM Adam Richter <adamrichter4@gmail.com> wrote:
>
> Hi.
>
> In arch/ia64/kernel/trace.c, ftrace_make_nop() apparently can call
> ftrace_modify_code() with second parameter (old_code) set to NULL,
> which ftrace_make_nop can dereference.  I have attached an appended an
> untested patch which I think should cause ftrace_modify_code to avoid
> the pointer dereference when old_code is null.
>
> I am not an Itanium developer or user but just want to submit what I
> think is a fix for a bug that cppcheck pointed me to.  I have not even
> tried to compile with this patch.  So, please feel free to replace
> this with a patch more to your liking.
>
> It has been a long time since I tried to submit a Linux kernel patch,
> so I am not up to date on the latest process requirements.  I hereby
> release my copyright interest in this patch to the public domain and
> state that, to the best of my knowledge, my contribution does not add
> anyone else's copyright interests or other intellectual property.
> This contribution should not be taken to imply my agreement,
> disagreement or making of any "pledge" with respect to any "code of
> conduct" or other terms.  If you need me to make some other statement
> or do something else, please just let me know.
>
> Thanks in advance for considering this patch.
>
> Adam Richter
>
> diff --git a/arch/ia64/kernel/ftrace.c b/arch/ia64/kernel/ftrace.c
> index 7fc8c961b1f7..98085dcbf20a 100644
> --- a/arch/ia64/kernel/ftrace.c
> +++ b/arch/ia64/kernel/ftrace.c
> @@ -114,7 +114,8 @@ ftrace_modify_code(unsigned long ip, unsigned char
> *old_code,
>                 return -EFAULT;
>
>         /* Make sure it is what we expect it to be */
> -       if (memcmp(replaced, old_code, MCOUNT_INSN_SIZE) != 0)
> +       if (old_code != NULL &&
> +           memcmp(replaced, old_code, MCOUNT_INSN_SIZE) != 0)
>                 return -EINVAL;
>
>  skip_check:
