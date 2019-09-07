From: Andy Lutomirski <luto@amacapital.net>
Date: Sat, 07 Sep 2019 17:42:23 +0000
Subject: Re: [PATCH v12 11/12] open: openat2(2) syscall
Message-Id: <C81D6D29-F6BF-48E6-A15E-3ABCB2C992E5@amacapital.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190904201933.10736-1-cyphar@cyphar.com> <20190904201933.10736-12-cyphar@cyphar.com> <7236f382d72130f2afbbe8940e72cc67e5c6dce0.camel@kernel.org> <CAHk-=whZx97Nm-gUK0ppofj2RA2LLz2vmaDUTKSSV-+yYB9q_Q@mail.gmail.com>
In-Reply-To: <CAHk-=whZx97Nm-gUK0ppofj2RA2LLz2vmaDUTKSSV-+yYB9q_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jeff Layton <jlayton@kernel.org>, Aleksa Sarai <cyphar@cyphar.com>, Al Viro <viro@zeniv.linux.org.uk>, "J. Bruce Fields" <bfields@fieldses.org>, Arnd Bergmann <arnd@arndb.de>, David Howells <dhowells@redhat.com>, Shuah Khan <shuah@kernel.org>, Shuah Khan <skhan@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Christian Brauner <christian@brauner.io>, Eric Biederman <ebiederm@xmission.com>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Alexei Starovoitov <ast@kernel.org>, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, Tycho Andersen <tycho@tycho.ws>, David Drysdale <drysdale@google.com>, Chanho Min <chanho.min@lge.com>, Oleg Nesterov <oleg@redhat.com>



> On Sep 7, 2019, at 9:58 AM, Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
>> On Sat, Sep 7, 2019 at 5:40 AM Jeff Layton <jlayton@kernel.org> wrote:
>> 
>> After thinking about this a bit, I wonder if we might be better served
>> with a new set of OA2_* flags instead of repurposing the O_* flags?
> 
> I'd hate to have yet _another_ set of translation functions, and
> another chance of people just getting it wrong either in user space or
> the kernel.
> 
> So no. Let's not make another set of flags that has no sane way to
> have type-safety to avoid more confusion.
> 
> The new flags that _only_ work with openat2() might be named with a
> prefix/suffix to mark that, but I'm not sure it's a huge deal.
> 
>            

I agree with the philosophy, but I think it doesn’t apply in this case.  Here are the flags:

O_RDONLY, O_WRONLY, O_RDWR: not even a proper bitmask. The kernel already has the FMODE_ bits to make this make sense. How about we make the openat2 permission bits consistent with the internal representation and let the O_ permission bits remain as an awful translation.  The kernel already translates like this, and it already sucks.

O_CREAT, O_TMPFILE, O_NOCTTY, O_TRUNC: not modes on the fd at all.  These affect the meaning of open().  Heck, for openat2, NOCTTY should be this default.

O_EXCL: hopelessly overloaded.

O_APPEND, O_DIRECT, O_SYNC, O_DSYNC, O_LARGEFILE, O_NOATIME, O_PATH, O_NONBLOCK: genuine mode bits

O_CLOEXEC: special because it affects the fd, not the struct file.

Linus, you rejected resolveat() because you wanted a *nice* API that people would use and that might even be adopted by other OSes. Let’s please not make openat2() be a giant pile of crap in the name of consistency with open().  open(), frankly, is horrible.
