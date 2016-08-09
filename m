From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Date: Tue, 09 Aug 2016 14:24:29 +0000
Subject: Re: [RFC v3 00/13] linux: generalize sections, ranges and linker tables
Message-Id: <20160809152429.5bb1c077@lxorguk.ukuu.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@lists.xen

> table development go under copyleft-next, Rusty recently asked for code
> to go in prior to the license tag being added denoting this license as
> GPL-compatible [3] -- I had noted in the patch submission which annotated
> copyleft-next's compatibility to GPLv2 that copyleft-next is the license
> of choice for ongoing kernel development on my end [4]. If this is
> objectionable I'm happy to change it to GPLv2 however I'd like a reason
> provided as I've gone through all possible channels to ensure this is kosher,
> including vetting by 3 attorneys now, 2 at SUSE.

You don't need a new tag, you can use "GPL" or "GPL and additional
rights". In fact you don't want any other tag because when combined with
the kernel it is GPLv2 anyway because the only way the two are fully
compatible is for the kernel community to license the derived work under
the GPL.

The second reason you must use the GPL or GPL with additional tag is
clause 8. We don't want anyone to create a module under your licence,
claim it is "open source" then fifteen years later release the module in
binary only form still with a tag saying "copyleft-next" which we treat
as GPL compatible. It's the same reason we don't have a BSD tag but use
"GPL with additional rights" to stop abuse of the module tags.

However you need to clarify the licence first I think. Linux is GPLv2,
your document only allows use of GPL with "GPL" works - not GPL v2 works ?

As PS: btw your licence is kind of weird. I can combine it with GPL work,
make it GPL therefore, and then use the GPL rights to remove the bits I
added thereby meaning I have your exact original work under the GPL. Not
sure how it's intended to work ?

It would also be good if someone clarified whether 6 and 7 are intended
to combine so you can take contributed patches and put them in your own
proprietary version. As a non-lawyer the intent is not clear at all.

Alan
