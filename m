From: =?iso-8859-1?q?Shiju=20A=20Mathew?= <shiju_m@yahoo.com>
Date: Wed, 12 Nov 2003 07:03:21 +0000
Subject: Odd IA32 mmap calls - Is this fixed
Message-Id: <marc-linux-ia64-106862063402317@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
The mummap is failing to unmap the pages allocated by
mmap when a ia32 application ( 4k Pagesize) is run on
ia64 system( 16k pagesize). This happens when the
offset  in mmap does not fall on 16k boundary. The
problem seems to be similar to the problem " Odd IA32
mmap calls" (Calls to mmap/munmap where the length is
a fraction of the page size cause a memory leak,
eventually running out of VM for the IA32 process)
listed in the ToDo list of ia64 homepage.I am doing
the test on sles-8 running 2.4.19 kernel. Is this
problem fixed in the 2.6 test kernel ? If it is not
fixed are there anyone working on it to fix the
problem?

Thanks & Regards,
Shiju

________________________________________________________________________
Want to chat instantly with your online friends?  Get the FREE Yahoo!
Messenger http://mail.messenger.yahoo.co.uk
