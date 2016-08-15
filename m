From: Steven Rostedt <rostedt@goodmis.org>
Date: Mon, 15 Aug 2016 21:00:55 +0000
Subject: Re: [RFC v3 00/13] linux: generalize sections, ranges and linker tables
Message-Id: <20160815170055.248eee3e@gandalf.local.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
	<20160809152429.5bb1c077@lxorguk.ukuu.org.uk>
	<1470758947.2299.47.camel@HansenPartnership.com>
	<CALCETrVmDhPC6BMu4_xTanSFZBKeW9V6A4SeQ4qxnpVod-eLbQ@mail.gmail.com>
	<1471292106.5944.3.camel@linux.intel.com>
In-Reply-To: <1471292106.5944.3.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alan Cox <alan@linux.intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>, James Bottomley <James.Bottomley@hansenpartnership.com>, benh@kernel.crashing.org, masami.hiramatsu.pt@hitachi.com, linux@rasmusvillemoes.dk, linux-kbuild@vger.kernel.org, linux-sh@vger.kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dwmw2@infradead.org, xen-devel@lists.xensource.com, "Luis R. Rodriguez" <mcgrof@kernel.org>, anil.s.keshavamurthy@intel.com, will.deacon@arm.com, linux-ia64@vger.kernel.org, x86@kernel.org, korea.drzix@gmail.com, mingo@redhat.com, andrew.cooper3@citrix.com, jgross@suse.com, tglx@linutronix.de, keescook@chromium.org, ananth@linux.vnet.ibm.com, jpoimboe@redhat.com, hpa@zytor.com, arnd@arndb.de, davem@davemloft.net, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, platform-driver-x86@vger.kernel.org, jkosina@suse.cz, david.vrabel@citrix.com, realmz6@gmail.com, fontana@sharpeleven

On Mon, 15 Aug 2016 21:15:06 +0100
Alan Cox <alan@linux.intel.com> wrote:

> > This is the module tag ... it says what licence the module is under,
> > not the licence for the module combined with the kernel, which is
> > always GPLv2 because the stricter licence rules.  
> 
> Because if I build a BSD licensed module against the kernel, give you
> the binaries and refuse to give you the source I am conforming to the
> BSD licence in letter. So to use it with the kernel it needs to be GPL
> with additional rights (eg BSD including the source...)
> 

But that only pertains to the code that was modified to be used with
the Linux kernel, right? That is, if there's a BSD licensed module for
device FOO, and I port it to the Linux kernel, that will need to have a
GPL added to it to be included in Linux. But the original BSD code is
not affected. If a fix is made to the GPL Linux version, I'm assuming
(because I've been asked when doing something like this), that the
author of that fix will have to give it a dual license to be used back
in the original BSD only code. Correct?

I'm just trying to understand this. From what would make sense to me
(but may or may not to a court of law, where it counts), is that the
code added to Linux must be under GPL. But using that code depends on
where you get it from. If you use BSD source, it stays under BSD. But
any fixes to the GPL version will require permission to be put back to
the BSD version. A change to the GPL version doesn't automatically get
allowed back to the BSD only version?

-- Steve
