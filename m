From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 16 Oct 2003 01:20:25 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106626735826691@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 16 Oct 2003 09:40:28 +1000, Neil Brown <neilb@cse.unsw.edu.au> said:

  >> So it looks to me like exportfs supports only 32-bit ino_t?

  Neil> Looks can be deceiving (especially when those /* */ operators
  Neil> haven't been used correctly).

  Neil> get_object is part of the legacy support in exportfs, where
  Neil> legacy really means ext2/ext3.  Any filesystem that actually
  Neil> used 64bit inode numbers would need to define it's own
  Neil> export_operations->get_dentry function which can interpret the
  Neil> file handle however it likes, including using 64 bits of it
  Neil> for an inode number (though such a filesystem probably
  Neil> wouldn't work with NFSv2, but that's OK).

Ah, that sounds good then.

  >>  (Neil, to give you some background: we'd like to change ino_t on
  >> ia64 from 32 to 64 bits and found that the only potential ABI
  >> issue is due to NFS; "struct nfsctl_export" is definitely an
  >> issue, but perhaps we can live with that.  I'm less certain about
  >> any issues exportfs might have.)

  Neil> ex_ino in nfsctl_export is not actually used, so all that is
  Neil> needed is to make sure user_space and kernel_space agree on
  Neil> the side of the field.  Maybe a __kernel_old_ino_t or
  Neil> soemthing.  But I would be quite happy to #ifdef out that
  Neil> system call for ia64 if that was preferred.

  Neil> So in short: there is no big problem, and the small problem is
  Neil> largely one of aesthetics.

OK, perhaps for now you could use Nathan's #ifdef __ia64__?  Something
along the lines of __kernel_old_ino_t certainly would be cleaner, if
other arches need something similar.

	--daviad
