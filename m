From: Segher Boessenkool <segher@kernel.crashing.org>
Date: Fri, 11 Oct 2019 16:25:52 +0000
Subject: Re: [PATCH v2 01/29] powerpc: Rename "notes" PT_NOTE to "note"
Message-Id: <20191011162552.GK9749@gate.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191011000609.29728-1-keescook@chromium.org> <20191011000609.29728-2-keescook@chromium.org> <20191011082519.GI9749@gate.crashing.org> <201910110910.48270FC97@keescook>
In-Reply-To: <201910110910.48270FC97@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: Borislav Petkov <bp@alien8.de>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Michal Simek <monstr@monstr.eu>, x86@kernel.org, linux-ia64@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-xtensa@linux-xtensa.org, Dave Hansen <dave.hansen@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linuxppc-dev@lists.ozlabs.org, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-parisc@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, Rick Edgecombe <rick.p.edgecombe@intel.com>, Will Deacon <will@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org

On Fri, Oct 11, 2019 at 09:11:43AM -0700, Kees Cook wrote:
> On Fri, Oct 11, 2019 at 03:25:19AM -0500, Segher Boessenkool wrote:
> > On Thu, Oct 10, 2019 at 05:05:41PM -0700, Kees Cook wrote:
> > > The Program Header identifiers are internal to the linker scripts. In
> > > preparation for moving the NOTES segment declaration into RO_DATA,
> > > standardize the identifier for the PT_NOTE entry to "note" as used by
> > > all other architectures that emit PT_NOTE.
> > 
> > All other archs are wrong, and "notes" is a much better name.  This
> > segment does not contain a single "note", but multiple "notes".
> 
> True, but the naming appears to be based off the Program Header name of
> "PT_NOTE".

Ah, so that's why the kernel segment (which isn't text btw, it's rwx) is
called "load" :-P

(Not convinced.  Some arch just got it wrong, and many others blindly
copied it?  That sounds a lot more likely imo.)

> Regardless, it is an entirely internal-to-the-linker-script
> identifier, so I am just consolidating on a common name with the least
> number of collateral changes.

Yes, that's what I'm complaining about.

Names *matter*, internal names doubly so.  So why replace a good name with
a worse name?  Because it is slightly less work for you?


Segher

p.s. Thanks for doing this, removing the powerpc workaround etc. :-)
