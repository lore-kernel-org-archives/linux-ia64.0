From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 14 Nov 2002 19:37:07 +0000
Subject: Re: [Linux-ia64] Re: memcpy failure
Message-Id: <marc-linux-ia64-105590709805434@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805424@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805424@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Nov 2002 13:21:59 -0600, Mario Smarduch <cms063@email.mot.com> said:

  Mario> I'm referring to page faults and what handle_exception() does
  Mario> - regs->r8 = -EFAULT

In the case of memcpy(), there are no exception regions ("handlers"),
so handle_exception() won't do anything.  copy_user() is different
that way.

	--david

