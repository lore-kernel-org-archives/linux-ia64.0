From: Matt_Domsch@Dell.com
Date: Tue, 15 May 2001 12:13:31 +0000
Subject: RE: [Linux-ia64] EFI GPT tools ?
Message-Id: <marc-linux-ia64-105590693005577@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005576@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005576@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Some months ago, my colleague Josef Moellers posted
> a question on the availability of fdisk and friends
> with support for the EFI GPT. The tools on Redhat 7.1
> beta do not support this format, thus RedHat cannot
> be installed on GPT-Formatted disks.
> 
> Does anybody know if someone works on this problem,
> or do these tools already exist somewhere ?

I've made a patch to GNU parted to support partitioning disks with GPT.
There are two patches to parted 1.4.11 available at
http://domsch.com/linux/parted.  Apply the pmbrfix patch second.

To my knowledge, no one has tried modifying fdisk yet.  I haven't had the
time myself.

The kernel understands GPT-partitioned disks just fine.

Thanks,
Matt


-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Systems Group
Linux OS Development
www.dell.com/linux



