From: Paul Jackson <pj@sgi.com>
Date: Thu, 26 Jan 2006 19:14:19 +0000
Subject: Re: [PATCH 1/6] {set,clear,test}_bit() related cleanup
Message-Id: <20060126111419.54b1cc56.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com>
	<20060125112857.GB18584@miraclelinux.com>
	<20060126161426.GA1709@elf.ucw.cz>
In-Reply-To: <20060126161426.GA1709@elf.ucw.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pavel Machek <pavel@suse.cz>
Cc: mita@miraclelinux.com, linux-kernel@vger.kernel.org, rth@twiddle.net, ink@jurassic.park.msu.ru, rmk@arm.linux.org.uk, spyro@f2s.com, dev-etrax@axis.com, dhowells@redhat.com, ysato@users.sourceforge.jp, torvalds@osdl.org, linux-ia64@vger.kernel.org, takata@linux-m32r.org, linux-m68k@vger.kernel.org, gerg@uclinux.org, linux-mips@linux-mips.org, parisc-linux@parisc-linux.org, linuxppc-dev@ozlabs.org, linux390@de.ibm.com, linuxsh-dev@lists.sourceforge.net, linuxsh-shmedia-dev@lists.sourceforge.net, sparclinux@vger.kernel.org, ultralinux@vger.kernel.org, uclinux-v850@lsi.nec.co.jp, ak@suse.de, chris@zankel.net

Pavel wrote:
> cpu_set sounds *very* ambiguous. We have thing called cpusets,

Hmmm ... you're right.  I've worked for quite some time on both
of these, and hadn't noticed this similarity before.

Oh well.  Such is the nature of naming things.  Sometimes nice
names resemble other nice names in unexpected ways.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
