From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 23 May 2001 20:06:35 +0000
Subject: RE: [Linux-ia64] problems with ppp/pppd: put_user/copy_to_user
Message-Id: <marc-linux-ia64-105590693005658@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005655@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005655@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Do you have "ppp" compiled as a module?  There is a problem
with exception handling for modules ... I'm working on a
patch now.

-----Original Message-----
From: Bill Nottingham [mailto:notting@redhat.com]
Sent: Wednesday, May 23, 2001 11:57 AM
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] problems with ppp/pppd: put_user/copy_to_user


We've got a report of ppp not working; what happens is that it
puts in the log:
    Couldn't get channel number: bad address

when it sends the PPPIOCGCHAN ioctl.

However, if we replace the calls to put_user for
PPPIOCGCHAN & PPPIOCGFLAGS ioctls with copy_to_user,
it works fine. Shouldn't this not make any difference?

Bill

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


