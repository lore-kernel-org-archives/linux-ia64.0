From: Neil Brown <neilb@cse.unsw.edu.au>
Date: Wed, 15 Oct 2003 23:40:28 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106626130022447@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday October 15, davidm@napali.hpl.hp.com wrote:
> >>>>> On Tue, 14 Oct 2003 22:18:10 -0700, Andrew Morton <akpm@osdl.org> said:
> 
>   Andrew> David Mosberger <davidm@napali.hpl.hp.com> wrote:
> 
>   >>  NFS is nastier (ugly multiplexed syscalls...).
> 
>   Andrew> Well I think that whole interface is deprecated anyway and
>   Andrew> the new nfsutils doesn't use it - it uses exportfs instead.
> 
>   Andrew> You'd need to check with Neil, but if I'm right you could
>   Andrew> just say "use current nfsutils on ia64".
> 
> Ugh, looks like there may be some problems with exportfs itself?
> I see:
> 
> static struct dentry *get_object(struct super_block *sb, void *vobjp)
> {
> 	__u32 *objp = vobjp;
> 	unsigned long ino = objp[0];
> 	__u32 generation = objp[1];
> 
> 	return export_iget(sb, ino, generation);
> }
> 
> So it looks to me like exportfs supports only 32-bit ino_t?

Looks can be deceiving (especially when those /* */ operators haven't
been used correctly).

get_object is part of the legacy support in exportfs, where legacy
really means ext2/ext3.
Any filesystem that actually used 64bit inode numbers would need to
define it's own export_operations->get_dentry function which can
interpret the file handle however it likes, including using 64 bits of
it for an inode number (though such a filesystem probably wouldn't
work with NFSv2, but that's OK).

> 
> (Neil, to give you some background: we'd like to change ino_t on ia64
> from 32 to 64 bits and found that the only potential ABI issue is due
> to NFS; "struct nfsctl_export" is definitely an issue, but perhaps we
> can live with that.  I'm less certain about any issues exportfs might
> have.)

ex_ino in nfsctl_export is not actually used, so all that is needed is
to make sure user_space and kernel_space agree on the side of the
field.
Maybe a __kernel_old_ino_t or soemthing.
But I would be quite happy to #ifdef out that system call for ia64 if
that was preferred.


So in short: there is no big problem, and the small problem is largely
   one of aesthetics.

NeilBrown
