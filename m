From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 09 Feb 2001 20:04:42 +0000
Subject: Re: [Linux-ia64] TODO list
Message-Id: <marc-linux-ia64-105590693005131@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005124@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005124@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 9 Feb 2001 12:01:45 -0800, Don Dugger <n0ano@valinux.com> said:

  Don> It also isn't as easy to do as you might think.  We were
  Don> looking into this at one time and you have to be really
  Don> carefull about stack management because you can wind up running
  Don> in kernel mode with a user stack pointer.  This would cause
  Don> serious problems when an interrupt comes in.

While I agree with the sentiment, I'd phrase it a little differently:
it's not difficult to fix the assumption of "psr.cpl=0 => we're on
the kernel stack".  The difficulty is in proving that you fixed all
the code that made that assumption...

	--david

