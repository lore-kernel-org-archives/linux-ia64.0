From: "John David Anglin" <dave@hiauly1.hia.nrc.ca>
Date: Fri, 27 Jan 2006 00:28:29 +0000
Subject: Re: [parisc-linux] Re: [PATCH 3/6] C-language equivalents of
Message-Id: <200601270028.k0R0STBB021468@hiauly1.hia.nrc.ca>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20060126230443.GC13632@colo.lackof.org> from "Grant Grundler" at Jan 26, 2006 04:04:43 pm
References: <Pine.LNX.4.64.0601261128280.16649@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.64.0601261128280.16649@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <grundler@parisc-linux.org>
Cc: grundler@parisc-linux.org, mita@miraclelinux.com, linux-kernel@vger.kernel.org, ink@jurassic.park.msu.ru, spyro@f2s.com, dev-etrax@axis.com, dhowells@redhat.com, ysato@users.sourceforge.jp, torvalds@osdl.org, linux-ia64@vger.kernel.org, takata@linux-m32r.org, linux-m68k@vger.kernel.org, gerg@uclinux.org, linux-mips@linux-mips.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, linuxsh-dev@lists.sourceforge.net, linuxsh-shmedia-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, uclinux-v850@lsi.nec.co.jp, ak@suse.de, chris@zankel.net

> Yeah, about the same for parisc.
> 
> > Clearly the smallest of the lot with the smallest register pressure,
> > being the best candidate out of the lot, whether we inline it or not.
> 
> Agreed. But I expect parisc will have to continue using it's asm
> sequence and ignore the generic version. AFAIK, the compiler isn't that
> good with instruction nullification and I have other issues I'd
> rather work on.

I looked at the assembler code generated on parisc with 4.1.0 (prerelease).
The toernig code is definitely inferior.  The mita sequence is four
instructions longer than the arm sequence, but it didn't have any branches.
The arm sequence has four branches.  Thus, it's not clear to me which
would perform better in the real world.  There were no nullified instructions
generated for any of the sequences.  However, neither is as good as the
handcraft asm sequence currently being used.

Dave
-- 
J. David Anglin                                  dave.anglin@nrc-cnrc.gc.ca
National Research Council of Canada              (613) 990-0752 (FAX: 952-6602)
