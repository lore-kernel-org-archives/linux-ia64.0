From: Matt_Domsch@Dell.com
Date: Wed, 07 Mar 2001 13:35:09 +0000
Subject: RE: [Linux-ia64] Two questions
Message-Id: <marc-linux-ia64-105590693005255@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005254@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005254@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 2. Where the <beep> are files on EFI GID partitions stored?? 
> I cleared the
> first disk for a brand new install but "old" booting files 
> are still there!

Since the GPT stores metadata at both the beginning 34 sectors of the disk
and a backup on the last 33 sectors of the disk,
you'll need to zero both sets of sectors for it to be "cleared".

Thanks,
Matt

-- 
Matt Domsch
Dell Linux Systems Group
Linux OS Development
www.dell.com/linux



