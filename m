From: Borislav Petkov <bp@alien8.de>
Date: Mon, 04 Nov 2019 08:59:18 +0000
Subject: Re: [PATCH v2 01/29] powerpc: Rename "notes" PT_NOTE to "note"
Message-Id: <20191104085918.GA7862@zn.tnic>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191011000609.29728-1-keescook@chromium.org>
 <20191011000609.29728-2-keescook@chromium.org>
 <20191011082519.GI9749@gate.crashing.org>
 <201910110910.48270FC97@keescook>
 <20191011162552.GK9749@gate.crashing.org>
 <20191015165412.GD596@zn.tnic>
 <201910291414.F29F738B7@keescook>
 <20191030010117.GJ28442@gate.crashing.org>
In-Reply-To: <20191030010117.GJ28442@gate.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Segher Boessenkool <segher@kernel.crashing.org>
Cc: Kees Cook <keescook@chromium.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Michal Simek <monstr@monstr.eu>, x86@kernel.org, linux-ia64@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-xtensa@linux-xtensa.org, Dave Hansen <dave.hansen@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linuxppc-dev@lists.ozlabs.org, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-parisc@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, Rick Edgecombe <rick.p.edgecombe@intel.com>, Will Deacon <will@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org

On Tue, Oct 29, 2019 at 08:01:17PM -0500, Segher Boessenkool wrote:
> I am still not convinced the worse name is a better name, no :-)  But if
> you don't want to do the work, and instead prefer the much smaller change,
> that is of course a fine decision.  Thank you!
>
> (I would be happy with such a 30/29 as well, of course.)

Ok, thanks.

I'll start picking up the pile and the renaming patch can then go ontop.

-- 
Regards/Gruss,
    Boris.

https://people.kernel.org/tglx/notes-about-netiquette
