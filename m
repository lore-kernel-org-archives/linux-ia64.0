From: Matt_Domsch@Dell.com
Date: Tue, 26 Mar 2002 12:58:30 +0000
Subject: [Linux-ia64] RE: [PATCH]fix for double free in efi.c
Message-Id: <marc-linux-ia64-105590701905337@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The following is a fix for a double free bug in fs/partitions/efi.c.

Indeed, this was pointed out a couple weeks ago and since fixed in the IA-64
port.  I'm readying a cleanup around EFI's use of GUIDs which affects
fs/partitions/efi.[ch] too and hope to have that ready to submit yet this
week.

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
#1 US Linux Server provider for 2001! (IDC Mar 2002)

