From: Doug Beattie <dbb@caldera.com>
Date: Fri, 14 Sep 2001 14:30:22 +0000
Subject: Re: [Linux-ia64] Location of absolute IA32 shared objects.
Message-Id: <marc-linux-ia64-105590698805181@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805122@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805122@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I just noticed a comment was posted on 2001-08-15 to the LSB tracking
task on this subject, that a post to fhs-discuss gave the solution to
the question of where ia32 vs ia64 libs should be placed.

`The /lib directory on x86 and IA64 will always contain the 32bit
libraries. IA64 systems should put their libraries in /lib64.' "This
way we don't need any special install hooks in the system, installer,
and package. It's all hardcoded." 

The description above are a paraphrase and direct quote from the post
to LSB task number 32642 that was used to track what should be done
for LSB compatibility.

Doug

David Mosberger wrote:
> 
> >>>>> On 10 Sep 2001 21:30:02 -0700, Ulrich Drepper <drepper@redhat.com> said:
> 
>   Uli> David Mosberger <davidm@hpl.hp.com> writes:
>   >> As far as I can see, neither LSB nor FHS address the issue of
>   >> where to place emulation files, so I'll propose a prefix of
>   >> "/emul/ia32-linux/" as a starter.  Any objections?
> 
>   Uli> Not that I care, but this is clearly a place for a new /proc
>   Uli> entry which can be changed by the sysadmin.
> 
> I'd have thought that this should be treated like "/": an unchanging
> prefix.  Mount, symlinks, and chroot are your friend.  Making it
> variable makes installation harder, as others have pointed out.  But
> it's not like I care a whole lot (as long as ia64 kernel performance
> isn't impacted noticably).
> 
>         --david
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Douglas B. Beattie
------------------
Linux Test Architect - Caldera, Inc.
dbb@caldera.com

