From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 15 Oct 2003 17:40:47 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106624019431589@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Nathan,

Based on the previous discussions, I applied your patch to change
ino_t to "unsigned long".  This fixes ustat() (for glibc) and breaks
nfsctl_export, but with reasonably recent nfsutils, that broken call
won't be used and exportfs seems to work fine (at least I was able to
mount an NFS filesystem from the patched box just fine).

Thanks,

	--david
