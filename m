From: "H. Peter Anvin" <hpa@zytor.com>
Date: Tue, 09 Sep 2014 03:20:49 +0000
Subject: Re: bit fields && data tearing
Message-Id: <540E7211.9020909@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <21512.10628.412205.873477@gargle.gargle.HOWL>			 <20140904090952.GW17454@tucnak.redhat.com>			 <540859EC.5000407@hurleysoftware.com>			 <20140904175044.4697aee4@alan.etchedpixels.co.uk>			 <5408C0AB.6050801@hurleysoftware.com>			 <20140905001751.GL5001@linux.vnet.ibm.com>			 <1409883098.5078.14.camel@jarvis.lan>		 <5409243C.4080704@hurleysoftware.com>			 <20140905040645.GO5001@linux.vnet.ibm.com>			 <1410066442.12512.13.camel@jarvis.lan>			 <20140907162146.GK5001@linux.vnet.ibm.com>		 <1410116687.2027.19.camel@jarvis.lan>	 <540CC305.8010407@hurleysoftware.com> <1410155407.2027.29.camel@jarvis.lan>	 <540E3BFF.7080307@hurleysoftware.com> <1410231392.2028.15.camel@jarvis.lan>
In-Reply-To: <1410231392.2028.15.camel@jarvis.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>, Peter Hurley <peter@hurleysoftware.com>
Cc: paulmck@linux.vnet.ibm.com, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Jakub Jelinek <jakub@redhat.com>, Mikael Pettersson <mikpelinux@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Henderson <rth@twiddle.net>, Oleg Nesterov <oleg@redhat.com>, Miroslav Franc <mfranc@redhat.com>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

On 09/08/2014 07:56 PM, James Bottomley wrote:
>>
>> Yeah, the extra requirement I added is basically nonsense, since the
>> only issue is what instructions the compiler is emitting. So if compiler
>> thinks the alignment is natural and combines the writes -- ok. If the
>> compiler thinks the alignment is off and doesn't combine the writes --
>> also ok.
> 
> Yes, I think I can agree that the only real problem is gcc thinking the
> store or load needs splitting.
> 

That seems much saner, and yes, that applies to any architecture which
needs unaligned references.  Now, if the references are *actually*
unaligned they can end up being split even on x86, especially if they
cross cache line boundaries.

	-hpa


