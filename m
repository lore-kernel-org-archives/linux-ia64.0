From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 15 Feb 2002 20:00:31 +0000
Subject: Re: [Linux-ia64] [PATCH] linux/fs/partitions/efi.c error handling
Message-Id: <marc-linux-ia64-105590701905112@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698806044@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698806044@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Feb 2002 10:11:19 -0700, Alex Williamson <alex_williamson@hp.com> said:

  Alex>    I was testing w/ some disks that appear to have bad
  Alex> partition tables and was getting the following error messages:

  Alex> SCSI device sdt: 35566480 512-byte hdwr sectors (18210 MB)
  Alex> sdt:<4> Warning: Disk has a valid GPT signature but invalid
  Alex> PMBR.  Use GNU Parted to correct disk.

  Alex> Unfortunately, that's not where the problem stopped.  I got
  Alex> random pointer dereference problems, and was apparently having
  Alex> data structures freed out from under them.  Turns out the
  Alex> find_valid_gpt() was freeing data structures more than once
  Alex> and passing back pointers to freed structures.  Patch below.

Applied, thanks!

	--david

