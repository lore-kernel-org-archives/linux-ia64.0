From: Jakub Jelinek <jakub@redhat.com>
Date: Thu, 04 Sep 2014 12:29:01 +0000
Subject: Re: bit fields && data tearing
Message-Id: <20140904122901.GA17454@tucnak.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140712181328.GA8738@redhat.com>
 <54079B70.4050200@hurleysoftware.com>
 <1409785893.30640.118.camel@pasglop>
 <21512.10628.412205.873477@gargle.gargle.HOWL>
 <20140904090952.GW17454@tucnak.redhat.com>
 <540859EC.5000407@hurleysoftware.com>
In-Reply-To: <540859EC.5000407@hurleysoftware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Hurley <peter@hurleysoftware.com>
Cc: Mikael Pettersson <mikpelinux@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Richard Henderson <rth@twiddle.net>, Oleg Nesterov <oleg@redhat.com>, Miroslav Franc <mfranc@redhat.com>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

On Thu, Sep 04, 2014 at 08:24:12AM -0400, Peter Hurley wrote:
> And I just confirmed with the Alpha cross-compiler that the fields are
> not 'padded out' if volatile either.

They can't be, struct layout is part of the ABI.
Guess you can introduce say atomic_bool and similar typedefs which would be
bool or char on most arches and on alpha int.

	Jakub
