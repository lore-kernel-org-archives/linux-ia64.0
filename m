From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Mon, 08 Sep 2014 19:09:29 +0000
Subject: Re: bit fields && data tearing
Message-Id: <1410203369.2027.56.camel@jarvis.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <5408C0AB.6050801@hurleysoftware.com>
		 <20140905001751.GL5001@linux.vnet.ibm.com>
		 <1409883098.5078.14.camel@jarvis.lan>
	 <5409243C.4080704@hurleysoftware.com>
		 <20140905040645.GO5001@linux.vnet.ibm.com>
		 <1410066442.12512.13.camel@jarvis.lan>
		 <20140907162146.GK5001@linux.vnet.ibm.com>
		 <1410116687.2027.19.camel@jarvis.lan>
		 <20140907230019.GO5001@linux.vnet.ibm.com>
		 <6092b453-e0c9-4f6d-922b-48bce988f774@email.android.com>
		 <20140907233655.GR5001@linux.vnet.ibm.com>
		 <154b540a-df47-4f3e-bdda-ab5d2e72723a@email.android.com>
	 <1410155802.2027.36.camel@jarvis.lan> <540DF17C.9080509@zytor.com>
In-Reply-To: <540DF17C.9080509@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: paulmck@linux.vnet.ibm.com, Peter Hurley <peter@hurleysoftware.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Jakub Jelinek <jakub@redhat.com>, Mikael Pettersson <mikpelinux@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Henderson <rth@twiddle.net>, Oleg Nesterov <oleg@redhat.com>, Miroslav Franc <mfranc@redhat.com>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

On Mon, 2014-09-08 at 11:12 -0700, H. Peter Anvin wrote:
> On 09/07/2014 10:56 PM, James Bottomley wrote:
> > On Sun, 2014-09-07 at 16:39 -0700, H. Peter Anvin wrote:
> >> How many PARISC systems do we have that actually do real work on Linux?
> > 
> > I'd be very surprised if this problem didn't exist on all alignment
> > requiring architectures, like PPC and Sparc as well.  I know it would be
> > very convenient if all the world were an x86 ... but it would also be
> > very boring as well.
> 
> I wouldn't be so sure about that.  That is a pretty aggressive
> relaxation of ordering that PARISC has enacted here, kind of like the
> Alpha "we don't need no stinking byte accesses".

Um, I think you need to re-read the thread; that's not what I said at
all. It's even written lower down: "PA can't do atomic bit sets (no
atomic RMW except the ldcw operation) it can do atomic writes to
fundamental sizes (byte, short, int, long) provided gcc emits the
correct primitive".  The original question was whether atomicity
required native bus width access, which we currently assume, so there's
no extant problem.

> > The rules for coping with it are well known and a relaxation of what we
> > currently do in the kernel, so I don't see what the actual problem is.
> > 
> > In the context of this thread, PA can't do atomic bit sets (no atomic
> > RMW except the ldcw operation) it can do atomic writes to fundamental
> > sizes (byte, short, int, long) provided gcc emits the correct primitive
> > (there are lots of gotchas in this, but that's not an architectural
> > problem).  These atomicity guarantees depend on the underlying storage
> > and are respected for main memory but not for any other type of bus.
> 
> So I'm not trying to push the "all the world is an x86"... certainly not
> given that x86 has abnormally strict ordering rules and so is itself an
> outlier.  What I *don't* really want to have to deal with is going
> through more than causal effort to accommodate outliers which no longer
> have any real value -- we have too much work to do.

What accommodation?  I was just explaining the architectural atomicity
rules on PA.  How they're bus dependent (which isn't a PA restriction)
and how the compiler can mess them up.  None of the current PA atomicity
rules conflicts with anything we do today ... the danger is that moving
to implicit atomicity gives us more scope for compiler problems ... but
that's not PA specific either; any architecture requiring alignment has
this problem.

James


