From: Matt_Domsch@Dell.com
Date: Thu, 10 Jan 2002 21:31:45 +0000
Subject: RE: [Linux-ia64] Re: Announce: kdb v2.0 is available for kernel 2
Message-Id: <marc-linux-ia64-105590698805799@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805789@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805789@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I would like to get crc32 in base as well but I believe that another
> person has been working on this as well.  If you like I will reconcile
> the two versions and get one crc32 into base kernel.

Jeff Garzik and I have I've been unsuccessful in getting crc32 into the base
kernels.  Jeff sent the patch once, I've sent the patch repeatedly.  Marcelo
looked at it and said he wanted to see it in 2.5.x first.  Linus has been
silent.

http://domsch.com/linux/patches/crc32/2.5.2-pre7/ has the current
implementation, broken into several smaller parts, and provided as one big
patch too.  Two additional drivers (de2140x.c and sis900.c) were modified
*after* the patch set was created and are also there; the
drivers/net/Makefile.lib needs to be touched to add those drivers to the
list - I haven't done that yet.

Keith, if you can get it in, I'd be glad for it.

Bugger is, when 2.5.x does away with fs/partitions/*, my need for the crc32
function in the kernel to support GPT dies too.  Progress I guess...

Thanks,
Matt

--
Matt Domsch
Sr. Software Engineer
Dell Linux Solutions www.dell.com/linux
#1 US Linux Server provider with 24.5% (IDC Dec 2001)
#2 Worldwide Linux Server provider with 18.2% (IDC Dec 2001)

