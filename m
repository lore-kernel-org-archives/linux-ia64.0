From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 07 Dec 2001 16:23:19 +0000
Subject: Re: [Linux-ia64] multimedia timer interface
Message-Id: <marc-linux-ia64-105590698805645@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805631@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805631@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jesse,

>>>>> On Thu, 6 Dec 2001 12:50:44 -0800, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> David, we talked awhile back about a generic timer interface
  Jesse> that we could use on SN platforms as a non-drifting
  Jesse> replacement for the ITC.  I've taken a look at the Intel
  Jesse> multimedia timer spec like you suggested and came up with the
  Jesse> following header file.  I've implemented it on our system
  Jesse> with some glibc changes to the hp timing routines and things
  Jesse> seem to work fine.  I'd like to get people's comments on the
  Jesse> ioctl interface though, because I'd like it to be useful on
  Jesse> other platforms as well.

Looks like good stuff to me!  I will have a couple of comments.
Unless it's urgent, I'd like to work on this mid next week.

  Jesse> Also, do you need me to resend the salinfo patch I posted
  Jesse> awhile back or are you just waiting for the SAL spec to get
  Jesse> updated?  I noticed it wasn't in the latest patch.

Yes, please resend.  I dropped the original patch because at that time
the ITC drift bit wasn't settled yet.

Thanks,

	--david

