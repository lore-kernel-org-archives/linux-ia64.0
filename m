From: Lenz Grimmer <grimmer@suse.de>
Date: Tue, 18 Sep 2001 09:03:26 +0000
Subject: Re: [Linux-ia64] PROPOSED: 32/64 bit coexistance
Message-Id: <marc-linux-ia64-105590698805203@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805193@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805193@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 18 Sep 2001, Jes Sorensen wrote:

> >>>>> "David" = David Mosberger <davidm@hpl.hp.com> writes:
>
> >>>>> On Mon, 17 Sep 2001 10:02:14 -0600, Doug Beattie <dbb@caldera.com> said:
> Doug> Your reponse is welcome and invited.  The LSB and FHS groups are
> Doug> trying to better address the coexistance of 32 and 64 bit in the
> Doug> 64 bit Itanium environment.
>
> Doug> Please review the following proposal and respond to the
> Doug> "lsb-spec@lists.linuxbase.org" and
> Doug> "lsb-discuss@lists.linuxbase.org" mail lists.
>
> David> When will people learn that for Linux, source compatibility is
> David> just as important as binary compatibility?  For IA-64 Linux,
> David> the decision was made that native libraries go into /lib etc
> David> and that legacy libraries go somewhere else
> David> (/usr/i386-*-linux/lib, commonly).
>
> Not to mention that ld.so has already been fixed to handle searching
> through library directories containing libraries for a different
> architecture than ld.so is running on itself. Hence the whole point of
> ia32 binaries being unable to cope with ia64 binaries in /lib is
> completely useless.
>
> It would have been extremely nice if the people who decided to write
> this standard had started out by asking the people who did the
> implementation work how the architecture really works and what
> experience has been gained in these areas already.

Who said, that this is already a "standard"? It's a proposal and you are
welcome to comment on it. It seems like everybody is aware of the problem
- this documents simply attempt to make sure, that we all play on the same
sheet of music and avoid yet another difference between implementations.

Bye,
	LenZ
-- 
------------------------------------------------------------------
 Lenz Grimmer                                           SuSE GmbH
 mailto:grimmer@suse.de                       Schanzaeckerstr. 10
 http://www.suse.de/~grimmer/            90443 Nuernberg, Germany
                 The trodden path is the safest.




