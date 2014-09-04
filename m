From: "H. Peter Anvin" <hpa@zytor.com>
Date: Thu, 04 Sep 2014 22:14:48 +0000
Subject: Re: bit fields && data tearing
Message-Id: <5408E458.3@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140712181328.GA8738@redhat.com>	 <54079B70.4050200@hurleysoftware.com> <1409785893.30640.118.camel@pasglop>	 <063D6719AE5E284EB5DD2968C1650D6D17487172@AcuExch.aculab.com> <1409824374.4246.62.camel@pasglop>
In-Reply-To: <1409824374.4246.62.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Laight <David.Laight@ACULAB.COM>
Cc: Peter Hurley <peter@hurleysoftware.com>, Jakub Jelinek <jakub@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Miroslav Franc <mfranc@redhat.com>, Richard Henderson <rth@twiddle.net>

On 09/04/2014 02:52 AM, Benjamin Herrenschmidt wrote:
> 
> Yeah correct, alpha and bytes right ? Is there any other ? That's why I
> suggested int.
> 

Even for Alpha it is only the 21064 AFAIK.

	-hpa


