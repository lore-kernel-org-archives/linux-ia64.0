From: Mario Smarduch <cms063@email.mot.com>
Date: Thu, 14 Nov 2002 19:21:59 +0000
Subject: Re: [Linux-ia64] Re: memcpy failure
Message-Id: <marc-linux-ia64-105590709805433@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805424@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805424@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Matthew Wilcox wrote:

> On Thu, Nov 14, 2002 at 10:09:34AM -0600, Mario Smarduch wrote:
> > Aren't all these routines suppose to return -EFAULT if a fault occurs?
>
> No.  Did you go to the Richard B Johnson school of C programming?
>
> --
> Revolutions do not require corporate support.

I'm referring to page faults and what handle_exception() does -  regs->r8 -EFAULT




