From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 04 Dec 2003 17:45:01 +0000
Subject: Re: [patch] 2.6.0-test9 pal/sal/salinfo/mca
Message-Id: <marc-linux-ia64-107056007816216@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106978478405713@msgid-missing>
In-Reply-To: <marc-linux-ia64-106978478405713@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 03 December 2003 6:38 pm, Ben Woodard wrote:
> We are currently basing our kernel off of the Red Hat Enterprise Linux 3
> kernel and we discovered that the implementation of MCA included with it
> does not work for us. The most obvious problem is that it never calls
> ia64_sal_clear_state_info after fetching a SAL record. Thus the CPE
> reasserts itself and the machine effectively locks up infinitely
> printing out the same CPE to the console.

I believe this is bug #104667 in the Red Hat bugzilla.  The patch
should be attached to the bug report.  I can't get bugzilla to show
me the report, so I don't know the current status.

> So my question is: should we continue forward with our backport of the
> 2.6 MCA code or is the 2.4 code actually functional enough to support
> our needs and we are missing something in our quick inspection of the
> code.

As Keith mentioned, the current 2.4 and 2.6 MCA code should be
essentially identical.

Bjorn

