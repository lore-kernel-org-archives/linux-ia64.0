From: Andrew Morton <akpm@osdl.org>
Date: Sat, 28 Feb 2004 10:23:23 +0000
Subject: Re: Oops in pdflush
Message-Id: <20040228022323.77e82981.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <je4qtl7u44.fsf@sykes.suse.de>
In-Reply-To: <je4qtl7u44.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens <kaos@sgi.com> wrote:
>
>  >So if I'm reading this right, we get a case that looks like unbounded
>  >recursion:
>  >
>  >	pdflush -> start_one_pdflush_thread -> kernel_thread -> pdflush ...
>  >

Yes.  Ow.  Thanks.

>  >Except, I don't think this is real recursion.  Instead, we effectively
>  >get a (potentially unbounded) sequence of one kernel thread creating
>  >another thread.  Each new kernel thread gets nested one deeper,
>  >eventually leading to a stack overflow...
>  >
>  >Hmmh, I think perhaps the right way to fix this is to use a separate
>  >continuation function, which will then take care of doing the
>  >child-specific actions.  Let me see if I can come up with something.
> 
>  Separate the pdflush thread creation and move it to a single master
>  thread.  This restricts the maximum stack depth already in use when
>  starting a worker pdflush thread.

We should use the new kthread infrastructure rather than open-coding it. 
It delegates thread startup to keventd and should thus avoid the stack
windup.

I'll take a look at this over the weekend unless someone else tell me
they're doing it.

