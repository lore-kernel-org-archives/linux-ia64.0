From: Matt_Domsch@Dell.com
Date: Fri, 01 Jun 2001 16:18:50 +0000
Subject: [Linux-ia64] RE: [PATCH] fix RAID autodetect on GPT-partitioned drives
Message-Id: <marc-linux-ia64-105590693005683@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The attached fixes RAID autodetection on GPT-partitioned drives;
> the code was never actually compiled before because
> CONFIG_AUTODETECT_RAID is a dead symbol.

Thanks for finding and fixing this Bill!

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions
www.dell.com/linux

