From: Bill Nottingham <notting@redhat.com>
Date: Wed, 23 May 2001 18:56:43 +0000
Subject: [Linux-ia64] problems with ppp/pppd: put_user/copy_to_user
Message-Id: <marc-linux-ia64-105590693005655@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We've got a report of ppp not working; what happens is that it
puts in the log:
    Couldn't get channel number: bad address

when it sends the PPPIOCGCHAN ioctl.

However, if we replace the calls to put_user for
PPPIOCGCHAN & PPPIOCGFLAGS ioctls with copy_to_user,
it works fine. Shouldn't this not make any difference?

Bill

