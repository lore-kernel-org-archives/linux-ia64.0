From: Nathan Scott <nathans@sgi.com>
Date: Wed, 15 Oct 2003 06:06:02 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106619832520344@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 14, 2003 at 09:47:41PM -0700, David Mosberger wrote:
> Hi Nathan,
> 
> Thanks for doing the thorough analysis!

No problem.  Thanks for the prodding. ;-)

> >>>>> On Wed, 15 Oct 2003 11:25:04 +1000, Nathan Scott <nathans@sgi.com> said:
> 
>   Nathan> system call interface -- I examined the 2.4 IA64 system call
>   Nathan> table and each of the structures passed across it in detail.
>   Nathan> This revealed that the ustat and NFS system calls pass around
>   Nathan> binary structures with __kernel_ino_t fields (see my updated
>   Nathan> patches).  I then diff'd the 2.4 and 2.6 asm-ia64/unistd.h
>   Nathan> and reviewed each of the new syscalls - there are no new 2.6
>   Nathan> interfaces that deal with an ino_t.
> 
> Those are nasty.  I suppose your patch works, but wouldn't it mean
> that NFS-export and/or ustat() of XFS file systems would fail?

It turns out that neither is a problem for us in practice.

In the case of ustat(2) ...
	ino_t     f_tinode;      /* Number of free inodes */
is meaningless on those filesystems (like XFS) which don't allocate a
fixed set of inodes at mkfs time.  It's only an "ino_t" for hysterical
raisins too (the count of free inodes? != an inode number!) - I notice
IRIX defines this in exactly the same way, I guess this came from SVR4
verbatim.  I'm hard pressed finding an application that uses this, and
I was quite surprised to find it in Linux at all.

For the NFS case - I asked one of the local NFS gurus to look over the
changes yesterday, and he tells me that field is only used to hold the
root inode number of a filesystem.  So, for XFS (and I'd imagine most
other filesystems too) this is never going to be a problem - the root
never has a large inode number in XFS because it's allocated at mkfs
time and always from the first allocation group (where inode numbers
are small).

> ...
> 1259 and 1260.  I don't expect/hope that other syscalls will be added
> this late in the game.

No, nor do I.  I don't think we should go that far though, certainly
it seems all our needs in XFS will be met without adding these calls.

cheers.

-- 
Nathan
