From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 27 Oct 2019 12:05:11 +0000
Subject: Re: [PATCH RESEND v14 2/6] namei: LOOKUP_IN_ROOT: chroot-like path resolution
Message-Id: <CAHk-=wjPPWvm5_eR4uaHJaU1isTUk-4iXQV3Z2Px9A+w6j2nHg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191026185700.10708-1-cyphar@cyphar.com> <20191026185700.10708-3-cyphar@cyphar.com>
In-Reply-To: <20191026185700.10708-3-cyphar@cyphar.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Aleksa Sarai <cyphar@cyphar.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>, Arnd Bergmann <arnd@arndb.de>, David Howells <dhowells@redhat.com>, Shuah Khan <shuah@kernel.org>, Shuah Khan <skhan@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Eric Biederman <ebiederm@xmission.com>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Alexei Starovoitov <ast@kernel.org>, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, Tycho Andersen <tycho@tycho.ws>, David Drysdale <drysdale@google.com>, Chanho Min <chanho.min@lge.com>, Oleg Nesterov <oleg@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

On Sat, Oct 26, 2019 at 2:58 PM Aleksa Sarai <cyphar@cyphar.com> wrote:
>
> +       /* LOOKUP_IN_ROOT treats absolute paths as being relative-to-dirfd. */
> +       if (flags & LOOKUP_IN_ROOT)
> +               while (*s = '/')
> +                       s++;
> +
>         /* Figure out the starting path and root (if needed). */
>         if (*s = '/') {
>                 error = nd_jump_root(nd);

So I'm still hung up on this.

I guess I can't help it, but I look at the above, and it makes me go
"whoever wrote those tests wasn't thinking".

It just annoys me how it tests for '/' completely unnecessarily.

If LOOKUP_IN_ROOT is true, we know the subsequent test for '/' is not
going to match, because we just removed it. So I look at that code and
go "that code is doing stupid things".

That's why I suggested moving the LOOKUP_IN_ROOT check inside the '/' test.

Alternatively, just make the logic be

        if (flags & LOOKUP_IN_ROOT) {
               .. remove '/'s ...
        } else if (*s = '/') {
                .. handl;e root ..

and remove the next "else" clause

    Linus
