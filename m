From: "McCaffity, Ray" <ray.mccaffity@wcg.com>
Date: Tue, 15 May 2001 14:46:52 +0000
Subject: RE: [Linux-ia64] EFI GPT tools ?
Message-Id: <marc-linux-ia64-105590693005578@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005576@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005576@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I guess I'm not really sure what GPT is, but is there any IA64
support journaled file systems yet?  (ReiserFS or JFS, etc..)
If this is the parted tool for partitioning, I have used that
on x86, but doesn't appear to support anything but ext2.

-----Original Message-----
From: Matt_Domsch@Dell.com [mailto:Matt_Domsch@Dell.com]
Sent: Tuesday, May 15, 2001 7:14 AM
To: Martin.Wilck@fujitsu-siemens.com; linux-ia64@linuxia64.org
Subject: RE: [Linux-ia64] EFI GPT tools ?


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



_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

