From: Rusty Russell <rusty@rustcorp.com.au>
Date: Tue, 11 Mar 2014 00:48:08 +0000
Subject: Re: [patch 10/20] kallsyms: fix absolute addresses for kASLR
Message-Id: <87k3c1y3k7.fsf@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k3c8yr9u.fsf@rustcorp.com.au>
In-Reply-To: <87k3c8yr9u.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kees Cook <keescook@chromium.org> writes:
> On Thu, Mar 6, 2014 at 7:20 PM, Rusty Russell <rusty@rustcorp.com.au> wrote:
>> What is "the x86 relocs tool"?
>
> arch/x86/tools/relocs.c is used to generate relocation information on
> x86-32 (always) and x86-64 (under kASLR). It deals with all kinds of
> weird special cases that various linkers do differently. I'm glad I
> didn't have to touch this code again. :)

Well, let's fix it!

Making these symbols absolute seems like the Right Thing.  We can work
around it for the moment but I'll look at that once we have a minimal
fix for now (see other thread).

Thanks,
Rusty.
