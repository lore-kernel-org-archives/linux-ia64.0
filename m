From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 24 Apr 2002 06:12:03 +0000
Subject: Re: [Linux-ia64] A start at large file and filesystem support
Message-Id: <marc-linux-ia64-105590701905508@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905504@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905504@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 24 Apr 2002 15:25:21 +1000, peterc@gelato.unsw.edu.au said:

  Peter> I've been looking at getting large file system support to
  Peter> work properly (there's currently a 1TB or 2TB limit on the
  Peter> size of a block device in 2.5.9, depending on how you use
  Peter> it).

  Peter> This patch enables large filesystems, and discs bigger than
  Peter> 2TB.  Only the EFI GUID partitioning scheme can be used with
  Peter> enormous discs, as all the others are constrained by 32-bit
  Peter> number of cylinders.

  Peter> Next step is to audit the filesystems that claim to be able
  Peter> to support large filesystems (ext2 may support up to 32TB;
  Peter> reiserfs version 4, jfs and xfs much more) and make sure that
  Peter> they can.

Good work!  Since this really doesn't touch any ia64 files: will you
work directly with the respective maintainers to get this into the
official 2.5 tree?

  Peter> The patch is a bit big for inclusion in this email.  You can
  Peter> get it from
  Peter> http://www.gelato.unsw.edu.au/patches/2.5.9-largefile-patch.txt.bz2
  Peter> (which also includes the changes David Mosberger put up as
  Peter> the diffs from 2.5.8)

  Peter> If you're bitkeeper-enabled, you can pull the patch from
  Peter> bk://gelato.unsw.edu.au:2022

Not sure how others feel about this, but I for one still like to get
diff -u-style patches.  It's just so much faster to get a quick idea
of what the patch does.

Thanks,

	--david


