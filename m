From: Michael Madore <mmadore@turbolinux.com>
Date: Tue, 13 Feb 2001 23:43:37 +0000
Subject: [Linux-ia64] 2.4.1 network problems
Message-Id: <marc-linux-ia64-105590693005146@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I am experiencing a lot of problems with 2.4.1 + David's patch on Lions.  If
I try to scp a file from another machine the network connection dies almost
immediately.  If I restrict the memory available to the kernel at boot time
to 1024MB, then the problem seems to go away.  I've tried this on 4 Lions,
all with the eepro100 card.

Has anyone else seen this?  I've had problems with the eepro100 before, but
things are much worse now.

-- 
Mike Madore
Software Engineer
TurboLinux, Inc.

