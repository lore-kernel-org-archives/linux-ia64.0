From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 09 Apr 2009 07:29:17 +0000
Subject: Re: cross-compilers
Message-Id: <10f740e80904090029j15451862ne6479d20ac704991@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090408003921.GA5054@ldl.fc.hp.com>
	 <20090408010331.GB10768@sgi.com> <20090408054612.GA6744@ldl.fc.hp.com>
	 <20090407225457.86f8a458.akpm@linux-foundation.org>
	 <20090409003308.GK16602@bilbo.ozlabs.org>
In-Reply-To: <20090409003308.GK16602@bilbo.ozlabs.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Andrew Morton <akpm@linux-foundation.org>, Alex Chiang <achiang@hp.com>, Robin Holt <holt@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

On Thu, Apr 9, 2009 at 02:33, Tony Breeds <tony@bakeyournoodle.com> wrote:
> On Tue, Apr 07, 2009 at 10:54:57PM -0700, Andrew Morton wrote:
>> We would benefit very much from having someone who actually maintains a
>> suite of cross-compilers for kernel developers.
>
> I build wont say maintain many of the cross compilers used for linux-next.  I
> can place them somehere.  They're kernel only as I don't build libc.

Any chance m68k-unknown-linux-gnu-gcc 4.0.2 can be updated, so we get proper
m68k allmodconfig coverage again? Recently we had some allmodconfig breakage
in mainline (not limited to m68k though) for stuff that had been in
-next, but was
never tried with m68k allmodconfig due to the ICE, while I could reproduce it.

Mine is gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-21), so
far no ICEs
when not trying randconfig (strange that randconfig triggers those).

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
