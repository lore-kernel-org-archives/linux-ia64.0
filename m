From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 14 Mar 2003 19:29:43 +0000
Subject: Re: [Linux-ia64] Re: [BUG] nanosleep() granularity bumps up in 2.5.64 (was: [PATCH]
Message-Id: <marc-linux-ia64-105590709806109@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806094@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806094@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 14 Mar 2003 15:34:36 +0100, Eric Piel <Eric.Piel@Bull.Net> said:

  Eric> Sure, I aim at porting the high resolution timers but any
  Eric> annoying bug related to the time can be interesting to remove.

Great!  It would be great to have someone who can focus on that.

  Eric> Any idea/sugestion/patch is welcomed. Whatever, I will try to
  Eric> fix this as soon as I'm back from my week end :-)

Does the x86 show the same behavior?  That would be a useful start to
narrow down the problem.

	--david

