From: Borislav Petkov <bp@alien8.de>
Date: Thu, 10 Oct 2019 10:40:29 +0000
Subject: Re: [PATCH 08/29] vmlinux.lds.h: Provide EMIT_PT_NOTE to indicate export of .notes
Message-Id: <20191010104029.GE7658@zn.tnic>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190926175602.33098-1-keescook@chromium.org>
 <20190926175602.33098-9-keescook@chromium.org>
In-Reply-To: <20190926175602.33098-9-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Thu, Sep 26, 2019 at 10:55:41AM -0700, Kees Cook wrote:
> In preparation for moving NOTES into RO_DATA, this provides a mechanism

s/this provides/provide/ - imperative tone. Check all your commit
messages pls.

-- 
Regards/Gruss,
    Boris.

https://people.kernel.org/tglx/notes-about-netiquette
