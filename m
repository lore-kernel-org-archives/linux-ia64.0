From: Keith Owens <kaos@melbourne.sgi.com>
Date: Tue, 24 Jul 2001 00:30:18 +0000
Subject: Re: [Linux-ia64] XFS / IA64 system call conflict
Message-Id: <marc-linux-ia64-105590693005884@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005867@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005867@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 23 Jul 2001 17:19:36 -0700, 
David Mosberger <davidm@hpl.hp.com> wrote:
>>>>>> On Tue, 24 Jul 2001 10:16:44 +1000, Keith Owens <kaos@melbourne.sgi.com> said:
>
>  Keith> There is no 'official' source for syscall numbers.
>
>Yes, there is: you send me mail, I add the respective numbers to
>unistd.h, and that's it.  Anyone who messes with that protocol is on
>his/her own.

Do you take care of glibc as well?  That is where the problem tends to
occur.

In any case the XFS syscalls are for the SGI version of ACLs.  There
are other projects working on ACLs, until there is agreement about the
ACL syscall interface, the XFS numbers cannot be considered to be
permanent.  So yes, we are on our own for the moment.


