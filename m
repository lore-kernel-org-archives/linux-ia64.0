From: Tim Riker <TimR@CalderaSystems.com>
Date: Thu, 10 Aug 2000 03:54:42 +0000
Subject: Re: [Linux-ia64] Processor Rev.
Message-Id: <marc-linux-ia64-105590678205304@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205295@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205295@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is some documentation on serial #s (the stickers not the
electronic IDs) in the Intel literature. In my "Intel Workstation SDV,
A1 Stepping Processor Replacement" manual there is a section on page 20
entitled "Identification of Upgrade Processor Stepping" with a table
mapping the 4 digit postfix to the A2 and A3 stepping. This also
includes some comments about the state of software revision detection.

I do not know if this info is truly public, so I have not copied this
info here. Perhaps someone from Intel would like to comment?

These postfixes are of the format Q[letter][number][number]. I would
assume there is a complete table available someplace that would include
A1-A3 and B0-B1 stepping maps, but I have not seen it.

The only reliable option I know of is to open a QuAD ticket on the
system and ask Intel.

Don Dugger wrote:
> 
> John-
> 
> The only way to find the revision that I know of is to check the
> paper work that came with your machine, that should list it.  There's
> no instruction that will give that information at this point in
> time.
> 
> On Wed, Aug 09, 2000 at 11:55:28AM -0400, John Baboval wrote:
> > What is a good way to check the processor revision on the lion machines. I
> > see people on the list refering to A1 or A2 stepping machines, but /proc/cpuinfo on
> > our machines only shows this:
> >
> > processor  : 3
> > vendor     : GenuineIntel
> > family     : IA-64
> > model      : Itanium
> > revision   : 0
> > archrev    : 0
> >
> > plus the serial numbers and MHz and such. Does this just mean we have old
> > CPUs, or is there a different way to check?
> >
> > --
> > John V. Baboval (baboval@missioncriticallinux.com)
> --
> Don Dugger
> "Censeo Toto nos in Kansa esse decisse." - D. Gale
> n0ano@valinux.com
> Ph: 303/938-9838
-- 
Tim Riker - http://rikers.org/ - short SIGs! <g>
All I need to know I could have learned in Kindergarten
... if I'd just been paying attention.

