From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 07 Mar 2003 22:28:48 +0000
Subject: Re: [Linux-ia64] Re: gas generates incorrect ia64 unwind rlen val ues
Message-Id: <marc-linux-ia64-105590709806006@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 17 January 2003 7:30 pm, David Mosberger wrote:
> OK, I checked this script into arch/ia64/scripts/unwcheck.sh now. 
> ...
> I also fixed the handful of problems it pointed out.  I agree that
> those are really gas bugs (except perhaps for the unwind info in
> gate.S, which was a bit clunky).  But for now, I fixed things by
> adding explicit nop's and commenting out .align directives.  The
> removal of .align may cost us a cycle or two in some routines, but I
> don't it's noticable in practice.

I applied these changes to 2.4 as well.

