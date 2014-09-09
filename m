From: "H. Peter Anvin" <hpa@zytor.com>
Date: Tue, 09 Sep 2014 02:27:14 +0000
Subject: Re: bit fields && data tearing
Message-Id: <540E6582.9020403@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <21512.10628.412205.873477@gargle.gargle.HOWL>			 <20140904090952.GW17454@tucnak.redhat.com>			 <540859EC.5000407@hurleysoftware.com>			 <20140904175044.4697aee4@alan.etchedpixels.co.uk>			 <5408C0AB.6050801@hurleysoftware.com>			 <20140905001751.GL5001@linux.vnet.ibm.com>			 <1409883098.5078.14.camel@jarvis.lan>		 <5409243C.4080704@hurleysoftware.com>			 <20140905040645.GO5001@linux.vnet.ibm.com>			 <1410066442.12512.13.camel@jarvis.lan>			 <20140907162146.GK5001@linux.vnet.ibm.com>		 <1410116687.2027.19.camel@jarvis.lan>	 <540CC305.8010407@hurleysoftware.com> <1410155407.2027.29.camel@jarvis.lan>	 <540E1587.3060108@tilera.com> <1410216228.2027.88.camel@jarvis.lan>
In-Reply-To: <1410216228.2027.88.camel@jarvis.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>, Chris Metcalf <cmetcalf@tilera.com>
Cc: Peter Hurley <peter@hurleysoftware.com>, paulmck@linux.vnet.ibm.com, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Jakub Jelinek <jakub@redhat.com>, Mikael Pettersson <mikpelinux@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Henderson <rth@twiddle.net>, Oleg Nesterov <oleg@redhat.com>, Miroslav Franc <mfranc@redhat.com>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

On 09/08/2014 03:43 PM, James Bottomley wrote:
> 
> This was years ago (possibly decades).  We had to implement in-kernel
> unaligned traps for the networking layer because it could access short
> and int fields that weren't of the correct alignment when processing
> packets.  It that's all corrected now, we wouldn't really notice (except
> a bit of a speed up since an unaligned trap effectively places the
> broken out instructions into the bit stream).
> 
> James
> 

Well, ARM doesn't trap, it just silently gives garbage on unaligned
memory references.

	-hpa


