From: Kees Cook <keescook@chromium.org>
Date: Thu, 10 Oct 2019 16:46:36 +0000
Subject: Re: [PATCH 07/29] x86: Restore "text" Program Header with dummy section
Message-Id: <201910100944.92CFB97157@keescook>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190926175602.33098-1-keescook@chromium.org>
 <20190926175602.33098-8-keescook@chromium.org>
 <20191010103305.GD7658@zn.tnic>
In-Reply-To: <20191010103305.GD7658@zn.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Borislav Petkov <bp@alien8.de>
Cc: Thomas Gleixner <tglx@linutronix.de>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 10, 2019 at 12:33:05PM +0200, Borislav Petkov wrote:
> On Thu, Sep 26, 2019 at 10:55:40AM -0700, Kees Cook wrote:
> > Instead of depending on markings in the section following NOTES to
> > restore the associated Program Header, use a dummy section, as done
> > in other architectures.
> 
> This is very laconic and after some staring at ld.info, I think you mean
> this:
> 
> "   If you place a section in one or more segments using ':PHDR', then
> the linker will place all subsequent allocatable sections which do not
> specify ':PHDR' in the same segments."
> 
> but I could be way off. Yes, no?
> 
> IOW, please write in the commit messages first what the problem is
> you're addressing.

Yeah, that's much improved. I really struggled to describe this, given
how weird the linker script logic is here.

> > --- a/arch/x86/kernel/vmlinux.lds.S
> > +++ b/arch/x86/kernel/vmlinux.lds.S
> > @@ -147,8 +147,9 @@ SECTIONS
> >  	} :text = 0x9090
> >  
> >  	NOTES :text :note
> > +	.dummy : { *(.dummy) } :text
> >  
> > -	EXCEPTION_TABLE(16) :text = 0x9090
> > +	EXCEPTION_TABLE(16)
> 
> This is killing the filler byte but I have a suspicion that'll change
> eventually to INT3... :)

Yes, though since the exception table isn't executable, filling with
0x90 has no meaning, and I think when I looked at the alignment there
were actually no fill bytes from here on. But it doesn't matter; it all
goes away in the end.

-- 
Kees Cook
