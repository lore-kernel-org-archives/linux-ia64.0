From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 14 Mar 2003 19:43:33 +0000
Subject: Re: [Linux-ia64] page size > 16KB
Message-Id: <marc-linux-ia64-105590709806112@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806057@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806057@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 14 Mar 2003 10:17:42 -0800, grundler@cup.hp.com (Grant Grundler) said:

  Grant> On Fri, Mar 14, 2003 at 01:33:12PM +0100, Jan Schreckenbach
  Grant> wrote:
  >> 2110715 cpu_idle 5996.3494 12975 sock_poll 81.0938

  Grant> As someone earlier mentioned, cpu_idle should be zero (or
  Grant> near zero).  I suspect you are IO bound - check mfg specs on
  Grant> IO cards and IO devices you are using. Then see what IO rate
  Grant> they are actually delivering (perhaps vmstat output is good
  Grant> enough).

And if it's disk I/O limited, you may want to try the 2.5 kernel,
since there have been a lot of scalability improves in the disk
subsystem.

	--david

