From: "Tian, Kevin" <kevin.tian@intel.com>
Date: Thu, 24 Jun 2004 02:57:53 +0000
Subject: RE: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <571ACEFD467F7749BC50E0A98C17CDD8046AD72A@pdsmsx403>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 6/24/2004 6:51AM, Bjorn Helgaas wrote:
>> (p6)	cmp.eq p7,p6=r27,r27 <----- Should here cmp.eq.unc be used
>> instead? No time to test it now...
>
>Your change evidently solves the problem, but I don't understand
>how.  Can you enlighten me?  Here's the essence of the code:
>
>	        cmp.eq p7,p6=r25,in0
>	(p6)    cmp.eq p7,p6=r26,r27
>	(p6)    br.cond.dpnt .map
>
>As I understand it, adding ".unc" to the second cmp instruction
>should only make a difference when p6=0.  In that case, after
>the old cmp (no ".unc") we'd have p6=0 and p7=1, while after
>the new cmp (with ".unc") we'd have p6=0 and p7=0.  But we
>never test p7, so I don't see what difference it makes.

Ah, agree with you on this point. So maybe this touch just affects sth
behind indirectly. I'm looking into it again... Anyone has a quick
answer? :)

Thanks,
Kevin
