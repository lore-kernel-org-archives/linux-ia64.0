From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 23 May 2001 20:15:00 +0000
Subject: Re: [Linux-ia64] problems with ppp/pppd: put_user/copy_to_user
Message-Id: <marc-linux-ia64-105590693005660@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005655@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005655@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 23 May 2001 14:56:43 -0400, Bill Nottingham <notting@redhat.com> said:

  Bill> We've got a report of ppp not working; what happens is that it
  Bill> puts in the log: Couldn't get channel number: bad address

  Bill> when it sends the PPPIOCGCHAN ioctl.

  Bill> However, if we replace the calls to put_user for PPPIOCGCHAN &
  Bill> PPPIOCGFLAGS ioctls with copy_to_user, it works
  Bill> fine. Shouldn't this not make any difference?

It should not make a difference.  Is there an easy test case that
reproduces the problem?

	--daivd

