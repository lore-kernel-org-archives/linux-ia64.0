From: Bill Nottingham <notting@redhat.com>
Date: Wed, 14 Feb 2001 20:47:29 +0000
Subject: [Linux-ia64] Re: 2.4.1 network problems
Message-Id: <marc-linux-ia64-105590693005152@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger (davidm@hpl.hp.com) said: 
> That's a rather bizarre bug.  I can confirm this is happening on one
> of our Lions as well.  The Big Sur (also with eepro100) is fine
> though.  The Lion has 4GB and the Big Sur only 1GB of RAM.

This sounds like the NFS hang we see from time to time; it
only happens on the Lions; BigSurs (even with 4GB) work fine.

Bill

