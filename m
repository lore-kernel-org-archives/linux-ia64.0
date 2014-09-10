From: "H. Peter Anvin" <hpa@zytor.com>
Date: Wed, 10 Sep 2014 20:18:06 +0000
Subject: Re: bit fields && data tearing
Message-Id: <5410B1FE.9090504@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140712181328.GA8738@redhat.com>	<54079B70.4050200@hurleysoftware.com>	<1409785893.30640.118.camel@pasglop>	<063D6719AE5E284EB5DD2968C1650D6D17487172@AcuExch.aculab.com>	<1409824374.4246.62.camel@pasglop>	<5408E458.3@zytor.com>	<54090AF4.7060406@hurleysoftware.com>	<54091B30.7080100@zytor.com>	<5409D76D.2070203@hurleysoftware.com>	<5409D9C0.7030403@zytor.com> <20140908185240.21f52ca0@alan.etchedpixels.co.uk>
In-Reply-To: <20140908185240.21f52ca0@alan.etchedpixels.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: Peter Hurley <peter@hurleysoftware.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Laight <David.Laight@ACULAB.COM>, Jakub Jelinek <jakub@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Miroslav Franc <mfranc@redhat.com>, Richard Henderson <rth@twiddle.net>, linux-alpha@vger.kernel.org

On 09/08/2014 10:52 AM, One Thousand Gnomes wrote:
> 
> I think the whole "removing Alpha EV5" support is basically bonkers. Just
> use set_bit in the tty layer. Alpha will continue to work as well as it
> always has done and you won't design out support for any future processor
> that turns out not to do byte aligned stores.
> 

I think it's pretty safe to say such a processor is unlikely to ever be
created, for the same reason there weren't any 48-bit computers when
32-bit computers ran out of steam: it caused more problems than it
solved, and Alpha pretty much proved that.  The engineering advantages
would have to be so overwhelmingly in favor for someone to want to walk
down that road again.

	-hpa


