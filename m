From: Bill Nottingham <notting@redhat.com>
Date: Tue, 16 Oct 2001 23:12:27 +0000
Subject: [Linux-ia64] Re: eepro100 hangs
Message-Id: <marc-linux-ia64-105590698805356@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Wilder (wilder@us.ibm.com) said: 
> We are seeing lockups of the eepro100 driver on an ia64 box running redhat
> 7.1 (Revision 1.36 of the eepro100 driver).  I have seen references to
> similar problems on this list but have not yet seen a resolution.  The
> problem is only seen with the eepro100 driver the e100 driver from intel
> works fine.  The system has 4 Gig of RAM.  Here are the details:

The HW has a bug.

You need to run eepro100-diag -f -G -w -w -w  to fix it.
You can get eepro100-diag from ftp.scyld.com; it's one of Donald Becker's
diagnostic tools.

Bill

