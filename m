From: William Lee Irwin III <wli@holomorphy.com>
Date: Fri, 15 Feb 2002 14:30:29 +0000
Subject: Re: [Linux-ia64] [PATCH] linux/fs/partitions/efi.c error handling
Message-Id: <marc-linux-ia64-105590701905108@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698806044@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698806044@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 14, 2002 at 10:11:19AM -0700, Alex Williamson wrote:
>    I was testing w/ some disks that appear to have bad partition
> tables and was getting the following error messages:
> SCSI device sdt: 35566480 512-byte hdwr sectors (18210 MB)
>  sdt:<4>  Warning: Disk has a valid GPT signature but invalid PMBR.
>   Use GNU Parted to correct disk.
> Unfortunately, that's not where the problem stopped.  I got
> random pointer dereference problems, and was apparently having
> data structures freed out from under them.  Turns out the
> find_valid_gpt() was freeing data structures more than once and
> passing back pointers to freed structures.  Patch below.

Is it just me or is this getting resent every couple of hours?
... something has gone horribly wrong.

Cheers,
Bill

