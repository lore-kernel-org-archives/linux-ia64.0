From: Chris Metcalf <cmetcalf@tilera.com>
Date: Mon, 08 Sep 2014 20:45:59 +0000
Subject: Re: bit fields && data tearing
Message-Id: <540E1587.3060108@tilera.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <21512.10628.412205.873477@gargle.gargle.HOWL>		 <20140904090952.GW17454@tucnak.redhat.com>		 <540859EC.5000407@hurleysoftware.com>		 <20140904175044.4697aee4@alan.etchedpixels.co.uk>		 <5408C0AB.6050801@hurleysoftware.com>		 <20140905001751.GL5001@linux.vnet.ibm.com>		 <1409883098.5078.14.camel@jarvis.lan>	 <5409243C.4080704@hurleysoftware.com>		 <20140905040645.GO5001@linux.vnet.ibm.com>		 <1410066442.12512.13.camel@jarvis.lan>		 <20140907162146.GK5001@linux.vnet.ibm.com>	 <1410116687.2027.19.camel@jarvis.lan> <540CC305.8010407@hurleysoftware.com> <1410155407.2027.29.camel@jarvis.lan>
In-Reply-To: <1410155407.2027.29.camel@jarvis.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>, Peter Hurley <peter@hurleysoftware.com>
Cc: paulmck@linux.vnet.ibm.com, "H. Peter Anvin" <hpa@zytor.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Jakub Jelinek <jakub@redhat.com>, Mikael Pettersson <mikpelinux@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Henderson <rth@twiddle.net>, Oleg Nesterov <oleg@redhat.com>, Miroslav Franc <mfranc@redhat.com>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

On 9/8/2014 1:50 AM, James Bottomley wrote:
> Actual alignment is pretty irrelevant.  That's why all architectures
> which require alignment also have to implement misaligned traps ... this
> is a fundamental requirement of the networking code, for instance.

Can you clarify what you think the requirement is?  The tile architecture
doesn't support misaligned load/store in general, but we do support it for
userspace (using a nifty JIT approach with a direct-map hash table kept
in userspace), and also for get_user/put_user.  But that's it, and,
the networking subsystem works fine for us.

Occasionally we report bugs for driver code that doesn't use the
get_unaligned_xxx() macros and friends, and our fixes are generally taken
upstream.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
