From: Matt Domsch <Matt_Domsch@dell.com>
Date: Thu, 20 Feb 2003 03:28:24 +0000
Subject: [Linux-ia64] Re: GPT_HEADER_REVISION_V1_02
Message-Id: <marc-linux-ia64-105590709805884@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> We'll issue a clarification on this topic. For now, can we have parted
> revert to GPT_HEADER_REVISION_V1_00 ?

No objections.  Will you be submitting a patch, or should I?

With this change, any time the partition table is updated, the old
version will get wiped out and replaced with the new version, which I
believe is the desired behavior.

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer, Architect
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com



