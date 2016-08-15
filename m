From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Mon, 15 Aug 2016 22:44:47 +0000
Subject: Re: [RFC v3 00/13] linux: generalize sections, ranges and linker tables
Message-Id: <1471301087.2428.48.camel@HansenPartnership.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
	 <20160809152429.5bb1c077@lxorguk.ukuu.org.uk>
	 <1470758947.2299.47.camel@HansenPartnership.com>
	 <CALCETrVmDhPC6BMu4_xTanSFZBKeW9V6A4SeQ4qxnpVod-eLbQ@mail.gmail.com>
In-Reply-To: <CALCETrVmDhPC6BMu4_xTanSFZBKeW9V6A4SeQ4qxnpVod-eLbQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Lutomirski <luto@amacapital.net>
Cc: benh@kernel.crashing.org, masami.hiramatsu.pt@hitachi.com, linux@rasmusvillemoes.dk, linux-kbuild@vger.kernel.org, linux-sh@vger.kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dwmw2@infradead.org, xen-devel@lists.xensource.com, "Luis R. Rodriguez" <mcgrof@kernel.org>, anil.s.keshavamurthy@intel.com, will.deacon@arm.com, linux-ia64@vger.kernel.org, x86@kernel.org, korea.drzix@gmail.com, mingo@redhat.com, andrew.cooper3@citrix.com, jgross@suse.com, tglx@linutronix.de, keescook@chromium.org, ananth@linux.vnet.ibm.com, jpoimboe@redhat.com, rostedt@goodmis.org, hpa@zytor.com, arnd@arndb.de, davem@davemloft.net, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, platform-driver-x86@vger.kernel.org, jkosina@suse.cz, david.vrabel@citrix.com, realmz6@gmail.com, fontana@sharpeleven.org, konrad.wilk@oracle.com, ananth@in.ibm.com, paul.gortmaker@windriver.c

On Tue, 2016-08-09 at 21:51 -0700, Andy Lutomirski wrote:
> On Aug 9, 2016 7:09 PM, "James Bottomley" <
> James.Bottomley@hansenpartnership.com> wrote:
> > 
> > On Tue, 2016-08-09 at 15:24 +0100, One Thousand Gnomes wrote:
> > > > table development go under copyleft-next, Rusty recently asked 
> > > > for code to go in prior to the license tag being added denoting
> > > > this license as GPL-compatible [3] -- I had noted in the patch
> > > > submission which annotated copyleft-next's compatibility to 
> > > > GPLv2 that copyleft-next is the license of choice for ongoing 
> > > > kernel development on my end [4]. If this is objectionable I'm 
> > > > happy to change it to GPLv2 however I'd like a reason provided 
> > > > as I've gone through all possible channels to ensure this is 
> > > > kosher, including vetting by 3 attorneys now, 2 at SUSE.
> > > 
> > > You don't need a new tag, you can use "GPL" or "GPL and 
> > > additional rights". In fact you don't want any other tag because 
> > > when combined  with the kernel it is GPLv2 anyway because the 
> > > only way the two are fully compatible is for the kernel community 
> > > to license the derived work under the GPL.
> > 
> > This is the module tag ... it says what licence the module is 
> > under, not the licence for the module combined with the kernel, 
> > which is always GPLv2 because the stricter licence rules.
> 
> Then why isn't "BSD" in the license_is_gpl_compatible list?

[Sorry about this, the list seems to have stopped sending me copies of
stuff I'm on the to: line for; not sure why.  Anyway, having fished
this copy out of my trash:]

It is, here specifically:

https://www.gnu.org/licenses/license-list.en.html#ModifiedBSD

James

