From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 09 Apr 2008 00:36:11 +0000
Subject: Re: [PATCH 1/2] ia64 kdump: add kdump_on_fatal_mca
Message-Id: <47FC0F7B.2080204@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47FAF533.8010707@jp.fujitsu.com>
In-Reply-To: <47FAF533.8010707@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> I saw the proposed
>> patch that changes the current behavior without mentioning it
>> at the summary, so i brought it up. ;)

Sorry about that.  It's my fault.

But as the result it was lucky that we can have a good
discussion about "required action after a fatal MCA".

> So far SGI are voting for enabling dumping for MCA, and
> Fujitsu have implicitly voted to disable (as that is what
> Seto-san's patch sets).  Any other opinions?

Ah, my vote can be invalid.
AFAIK, Fujitsu have both situation where kdump_on_fatal_mca
should be enabled and where it should be disabled.
Therefore I don't mind which is the default.
Anyway we need to put a line to /etc/sysctl.conf of one of both.

So now "enable vs disable" is not 1:1 but 1:0 or 1.5:0.5.

Tony, (if there are no other votes until your poll closing)
would you apply my patch modifying the default to 1?
Or I need to resend you all just modified the one byte?

Thanks,
H.Seto
