From: Noah Romer <nromer@lsil.com>
Date: Mon, 13 Aug 2001 13:55:04 +0000
Subject: [Linux-ia64] rwlock and atomic_sub on ia64
Message-Id: <marc-linux-ia64-105590698805063@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm in the process of adding support for the ia64 architecture to the 
message/fusion/mptlan.c driver (it's previously only been tested with 
i386 and sparc64 systems) and have come across a couple of issues:

1) there doesn't appear to be support for rwlocks under ia64. At least, 
I can't find any way to make the above driver link when it's got code 
that uses rwlocks.

and

2) atomic_sub looks to require that I cast a u8 to (int) when I pass it 
in as a parameter. Not a major issue, I just found it odd.

I'm most likely missing something (didn't see anything about either of 
the above when I looked through the list archive), but I was wondering 
if I could get a pointer or two from those with more knowledge of 
ia64/linux issues.

Thanks.

I'm not currently subscribed to linux-ia64, so please cc: me on replies.

-- 
Noah Romer
Driver Developer, CM gopher and Linux Whipping Boy
Storage Components Firmware
LSI Logic Corp.


