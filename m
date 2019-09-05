From: Christian Brauner <christian.brauner@ubuntu.com>
Date: Thu, 05 Sep 2019 18:35:32 +0000
Subject: Re: [PATCH v12 01/12] lib: introduce copy_struct_{to,from}_user helpers
Message-Id: <20190905183532.GA25049@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190904201933.10736-1-cyphar@cyphar.com>
 <20190904201933.10736-2-cyphar@cyphar.com>
 <20190905180750.GQ1131@ZenIV.linux.org.uk>
 <20190905182303.7f6bxpa2enbgcegv@wittgenstein>
 <20190905182801.GR1131@ZenIV.linux.org.uk>
In-Reply-To: <20190905182801.GR1131@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Aleksa Sarai <cyphar@cyphar.com>, Jeff Layton <jlayton@kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>, Arnd Bergmann <arnd@arndb.de>, David Howells <dhowells@redhat.com>, Shuah Khan <shuah@kernel.org>, Shuah Khan <skhan@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Christian Brauner <christian@brauner.io>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Eric Biederman <ebiederm@xmission.com>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Alexei Starovoitov <ast@kernel.org>, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, Tycho Andersen <tycho@tycho.ws>, David Drysdale <drysdale@google.com>, Chanho Min <chanho.min@lge.com>, Oleg Nesterov <oleg@r>

On Thu, Sep 05, 2019 at 07:28:01PM +0100, Al Viro wrote:
> On Thu, Sep 05, 2019 at 08:23:03PM +0200, Christian Brauner wrote:
> 
> > Because every caller of that function right now has that limit set
> > anyway iirc. So we can either remove it from here and place it back for
> > the individual callers or leave it in the helper.
> > Also, I'm really asking, why not? Is it unreasonable to have an upper
> > bound on the size (for a long time probably) or are you disagreeing with
> > PAGE_SIZE being used? PAGE_SIZE limit is currently used by sched, perf,
> > bpf, and clone3 and in a few other places.
> 
> For a primitive that can be safely used with any size (OK, any within
> the usual 2Gb limit)?  Why push the random policy into the place where
> it doesn't belong?

Ah, the "not in the helper part" makes sense.
As long as leave the check for the callers themselves.

> 
> Seriously, what's the point?  If they want to have a large chunk of
> userland memory zeroed or checked for non-zeroes - why would that
> be a problem?
