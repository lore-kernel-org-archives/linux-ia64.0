From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 11 Mar 2003 22:37:23 +0000
Subject: Re: [Linux-ia64] ia64_spinlock_contention and NEW_LOCK
Message-Id: <marc-linux-ia64-105590709806035@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806001@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806001@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 08 Mar 2003 00:57:04 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> 2.4.0-test6-ia64-000811 introduced ia64_spinlock_contention
  Keith> and NEW_LOCK.  AFAICT they have been disabled ever since they
  Keith> were introduced.  Are there any plans to use this NEW_LOCK
  Keith> code?

I still think it would make sense to have back-off logic in the
spinlock contention case, but given that I haven't had time to work on
it in the last 2 years and nobody else has expressed interest in it, I
think it's time to just nuke the code.  If someone wants to work on it
later on, it's been archived often enough that the code can be dug out
if necessary.

Thanks for reminding me.

	--david

