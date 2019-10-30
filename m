From: Segher Boessenkool <segher@kernel.crashing.org>
Date: Wed, 30 Oct 2019 01:01:17 +0000
Subject: Re: [PATCH v2 01/29] powerpc: Rename "notes" PT_NOTE to "note"
Message-Id: <20191030010117.GJ28442@gate.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191011000609.29728-1-keescook@chromium.org> <20191011000609.29728-2-keescook@chromium.org> <20191011082519.GI9749@gate.crashing.org> <201910110910.48270FC97@keescook> <20191011162552.GK9749@gate.crashing.org> <20191015165412.GD596@zn.tnic> <201910291414.F29F738B7@keescook>
In-Reply-To: <201910291414.F29F738B7@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: Borislav Petkov <bp@alien8.de>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Michal Simek <monstr@monstr.eu>, x86@kernel.org, linux-ia64@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-xtensa@linux-xtensa.org, Dave Hansen <dave.hansen@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linuxppc-dev@lists.ozlabs.org, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-parisc@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, Rick Edgecombe <rick.p.edgecombe@intel.com>, Will Deacon <will@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org

On Tue, Oct 29, 2019 at 02:15:39PM -0700, Kees Cook wrote:
> On Tue, Oct 15, 2019 at 06:54:13PM +0200, Borislav Petkov wrote:
> > On Fri, Oct 11, 2019 at 11:25:52AM -0500, Segher Boessenkool wrote:
> > > Names *matter*, internal names doubly so.  So why replace a good name with
> > > a worse name?  Because it is slightly less work for you?
> > 
> > So if we agree on the name "notes" and we decide to rename the other
> > arches, this should all be done in a separate patchset anyway, and ontop
> > of this one. And I believe Kees wouldn't mind doing it ontop since he's
> > gotten his hands dirty already. :-P
> 
> I've added more rationale to patch #1 in the just-sent v3 of this
> series. If I still can't convince you Segher, I'm happy to send "patch
> 30/29" to do a bulk rename to "notes". Let me know. :)

I am still not convinced the worse name is a better name, no :-)  But if
you don't want to do the work, and instead prefer the much smaller change,
that is of course a fine decision.  Thank you!

(I would be happy with such a 30/29 as well, of course.)


Segher
