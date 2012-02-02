From: Bernd Petrovitsch <bernd@petrovitsch.priv.at>
Date: Thu, 02 Feb 2012 09:28:42 +0000
Subject: RE: Memory corruption due to word sharing
Message-Id: <1328174924.12177.17.camel@thorin>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
	 <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
	 <1328118174.15992.6206.camel@triegel.csb>
	 <CA+55aFw=z2SKFGoSE5e_0ZmKcAAjK5q0DBM4PaxBH2D9tuikzA@mail.gmail.com>
	 <A3E67C2071F49C4CBC4F17E6D77CDDD232754151@G4W3299.americas.hpqcorp.net>
In-Reply-To: <A3E67C2071F49C4CBC4F17E6D77CDDD232754151@G4W3299.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Boehm, Hans" <hans.boehm@hp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Torvald Riegel <triegel@redhat.com>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "dsterba@suse.cz" <dsterba@suse.cz>, "ptesarik@suse.cz" <ptesarik@suse.cz>, "rguenther@suse.de" <rguenther@suse.de>, "gcc@gcc.gnu.org" <gcc@gcc.gnu.org>

On Mit, 2012-02-01 at 21:04 +0000, Boehm, Hans wrote:
[...]
> The C11 memory model potentially adds overhead in only two cases:
> 
> 1. When current code involves touching a field that wouldn't otherwise
> be touched.  There are odd cases in which this measurably slows down
> code, but I think all agree that we need it.  In addition to
> bitfields, it can affect speculatively promoting a value to a register
> in a loop, which at least older versions of gcc also do.

Just adding an -f option for this and/or activating it only for -O5 (or
whatever the highest level is) and - in case that feature is activated -
emit warnings if bitfields (and/or any other data types that might be
affected)?

Kind regards,
	Bernd
-- 
Bernd Petrovitsch                  Email : bernd@petrovitsch.priv.at
                     LUGA : http://www.luga.at

