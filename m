From: Keith Owens <kaos@melbourne.sgi.com>
Date: Tue, 24 Jul 2001 01:04:51 +0000
Subject: Re: [Linux-ia64] XFS / IA64 system call conflict
Message-Id: <marc-linux-ia64-105590693005886@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005867@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005867@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 23 Jul 2001 17:35:07 -0700, 
David Mosberger <davidm@hpl.hp.com> wrote:
>>>>>> On Tue, 24 Jul 2001 10:30:18 +1000, Keith Owens <kaos@melbourne.sgi.com> said:
>  Keith> In any case the XFS syscalls are for the SGI version of ACLs.
>  Keith> There are other projects working on ACLs, until there is
>  Keith> agreement about the ACL syscall interface, the XFS numbers
>  Keith> cannot be considered to be permanent.  So yes, we are on our
>  Keith> own for the moment.
>
>Fine by me provided you make sure that the users of XFS understand
>that.  It does sound though that it would be premature to recommend
>widespread use of XFS at this time.

On the contrary.  ACLs are an add on to XFS, you can run XFS quite
happily without ACLs.


