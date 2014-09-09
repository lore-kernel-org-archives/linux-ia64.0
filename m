From: "H. Peter Anvin" <hpa@zytor.com>
Date: Tue, 09 Sep 2014 02:30:29 +0000
Subject: Re: bit fields && data tearing
Message-Id: <540E6645.6040209@zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5408C0AB.6050801@hurleysoftware.com>			 <20140905001751.GL5001@linux.vnet.ibm.com>			 <1409883098.5078.14.camel@jarvis.lan>		 <5409243C.4080704@hurleysoftware.com>			 <20140905040645.GO5001@linux.vnet.ibm.com>			 <1410066442.12512.13.camel@jarvis.lan>			 <20140907162146.GK5001@linux.vnet.ibm.com>			 <1410116687.2027.19.camel@jarvis.lan>			 <20140907230019.GO5001@linux.vnet.ibm.com>			 <6092b453-e0c9-4f6d-922b-48bce988f774@email.android.com>			 <20140907233655.GR5001@linux.vnet.ibm.com>			 <154b540a-df47-4f3e-bdda-ab5d2e72723a@email.android.com>		 <1410155802.2027.36.camel@jarvis.lan> <540DF17C.9080509@zytor.com>	 <1410203369.2027.56.camel@jarvis.lan> <540DFFB2.4000509@zytor.com> <1410215994.2027.86.camel@jarvis.lan>
In-Reply-To: <1410215994.2027.86.camel@jarvis.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: paulmck@linux.vnet.ibm.com, Peter Hurley <peter@hurleysoftware.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Jakub Jelinek <jakub@redhat.com>, Mikael Pettersson <mikpelinux@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Henderson <rth@twiddle.net>, Oleg Nesterov <oleg@redhat.com>, Miroslav Franc <mfranc@redhat.com>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

On 09/08/2014 03:39 PM, James Bottomley wrote:
> 
> I don't understand what you mean by "pass each other".  Atomicity
> guarantees are not ordering guarantees in a SMP environment.  The
> guarantee is that if you follow the rules when two CPUs update the same
> natural width aligned object simultaneously using the same primitive,
> the result is either one or the other of their updates.  Which one wins
> (the ordering) isn't defined.
> 

I'm trying to figure out why it would possibly make a difference in any
kind of sane system if gcc fuses accesses.

Assuming bigendian for the moment, I would expect that if CPU 1 does a
write of 0x01020304 to address 0 and CPU 2 does a write of 0x0506 to
address 2, that the end result would be either 0x01020304 or 0x01020506.
 Similarly, I would expect that if these operations are both done on the
same CPU in that order, that the result would unambiguously be 0x01020506.

I would strongly suspect an architecture which does not provide those
guarantees is an outlier.

	-hpa


