From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 04 Dec 2003 20:05:48 +0000
Subject: Re: [patch] 2.6.0-test9 pal/sal/salinfo/mca
Message-Id: <marc-linux-ia64-107056849427500@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106978478405713@msgid-missing>
In-Reply-To: <marc-linux-ia64-106978478405713@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 04 December 2003 12:44 pm, Luck, Tony wrote:
> 
> > As Keith mentioned, the current 2.4 and 2.6 MCA code should be
> > essentially identical.
> 
> David deferred Keith's last MCA patch for 2.6.1 ... so the current
> checked in 2.6 code doesn't have the latest goodies.

Oops, you're right.  I forgot about that.

> Keith's patch can be found here:
>  http://marc.theaimsgroup.com/?l=linux-ia64&m6974968032730&w=2
> 
> Don't forget these all require a user level daemon to pick
> up CMC and CPE reports and log them in all their glory.
> 
> Keith: did you post salinfo-0.4 yet?  I haven't seen it.

He sent it to me last week, and I just now dropped it here:

	ftp://ftp.kernel.org/pub/linux/kernel/people/helgaas/salinfo-0.4.tar.gz

(Keith, this includes the patch you sent me on Tuesday).  Keith's done
some Red Hat packaging, too; anybody want to contribute Debian
packaging?

Bjorn

