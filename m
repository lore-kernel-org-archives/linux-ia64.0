From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 01 Feb 2005 17:46:43 +0000
Subject: Re: Kernel 2.4.21 hangs up
Message-Id: <16895.49283.929460.224645@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <41FF0281.6090903@yahoo.com.au>
	<20050201082001.43454.qmail@web51102.mail.yahoo.com>
In-Reply-To: <20050201082001.43454.qmail@web51102.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: baswaraj kasture <kbaswaraj@yahoo.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

[I trimmed the cc-list...]

>>>>> On Tue, 1 Feb 2005 00:20:01 -0800 (PST), baswaraj kasture <kbaswaraj@yahoo.com> said:

  Baswaraj> Hi, I compiled kernel 2.4.21 with intel compiler .

That's curious.  Last time I checked, the changes needed to use the
Intel-compiler have not been backported to 2.4.  What kernel sources
are you working off of?

Also, even with 2.6 you need a script from Intel which does some
"magic" GCC->ICC option translations to build the kernel with the
Intel compiler.  AFAIK, this script has not been released by Intel
(hint, hint...).

  Baswaraj> While booting it hangs-up . further i found that it
  Baswaraj> hangsup due to call to "calibrate_delay" routine in
  Baswaraj> "init/main.c". Also found that loop in the
  Baswaraj> callibrate_delay" routine goes infinite.

I suspect your kernel was just miscompiled.  We have used the
Intel-compiler internally on a 2.6 kernel and it worked fine at the
time, though I haven't tried recently.

	--david
