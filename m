From: Matt_Domsch@Dell.com
Date: Fri, 16 Aug 2002 16:48:18 +0000
Subject: RE: [Linux-ia64] [PATCH] fix raid on GPT partitions
Message-Id: <marc-linux-ia64-105590701905944@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905943@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905943@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>    Seems a minor number increment was missed in the efi partition
> code.  This was causing RAID to only autodetect if you were lucky
> enough to be using raid on the first partition of the disk.  Here's
> the fix (against 2.4.18+0722).

Good catch, thanks!

-Matt

--
Matt Domsch
Sr. Software Engineer, Lead Engineer, Architect
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
#1 US Linux Server provider for 2001 and Q1/2002! (IDC May 2002)


