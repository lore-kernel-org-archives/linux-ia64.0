From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 15 Oct 2003 04:47:41 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106619327617629@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Nathan,

Thanks for doing the thorough analysis!

>>>>> On Wed, 15 Oct 2003 11:25:04 +1000, Nathan Scott <nathans@sgi.com> said:

  Nathan> system call interface -- I examined the 2.4 IA64 system call
  Nathan> table and each of the structures passed across it in detail.
  Nathan> This revealed that the ustat and NFS system calls pass around
  Nathan> binary structures with __kernel_ino_t fields (see my updated
  Nathan> patches).  I then diff'd the 2.4 and 2.6 asm-ia64/unistd.h
  Nathan> and reviewed each of the new syscalls - there are no new 2.6
  Nathan> interfaces that deal with an ino_t.

Those are nasty.  I suppose your patch works, but wouldn't it mean
that NFS-export and/or ustat() of XFS file systems would fail?

ustat() we could handle pretty easily, by introducing a new syscall
number which uses the "long" ino_t.  Then we just write a small
wrapper for the old ustat() syscall.

NFS is nastier (ugly multiplexed syscalls...).  I suppose it could be
handled by incrementing NFSCTL_VERSION, but I'm not sure of all the
implications of doing that (probably not what we want).  Actually,
I think we could handle NFS the same way as ustat(): change the
ino_t to long and then have a wrapper for the old nfsctl() syscall
which passes through everything except for some nfsctl_export munging.

Do you want to try this?  If you do, you could use syscall numbers
1259 and 1260.  I don't expect/hope that other syscalls will be added
this late in the game.

	--david
