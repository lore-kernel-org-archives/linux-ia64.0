From: Jeff Law <law@redhat.com>
Date: Wed, 01 Feb 2012 19:54:48 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <4F299888.40307@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>	 <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com> <1328118174.15992.6206.camel@triegel.csb> <A3E67C2071F49C4CBC4F17E6D77CDDD23275408E@G4W3299.americas.hpqcorp.net>
In-Reply-To: <A3E67C2071F49C4CBC4F17E6D77CDDD23275408E@G4W3299.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Boehm, Hans" <hans.boehm@hp.com>
Cc: Torvald Riegel <triegel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "dsterba@suse.cz" <dsterba@suse.cz>, "ptesarik@suse.cz" <ptesarik@suse.cz>, "rguenther@suse.de" <rguenther@suse.de>, "gcc@gcc.gnu.org" <gcc@gcc.gnu.org>

On 02/01/2012 12:44 PM, Boehm, Hans wrote:

> C11 is a published standard.  Last I checked, gcc did not follow many of the above rules.  It looks like major changes were recently merged into the gcc trunk, and I haven't had a chance to test those, so it may well be fixed.  But more importantly, so far I haven't read anything here to dissuade me that they are the right target.

The bitfield changes didn't make it into gcc-4.7; we're still working 
through implementation details.   GCC's bitfield support is a horrid 
nasty mess which has made implementation of the standard problematical. 
   It's on Aldy's plate for gcc-4.8.

jeff
