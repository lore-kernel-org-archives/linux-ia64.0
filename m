From: Borislav Petkov <bp@alien8.de>
Date: Thu, 02 Mar 2023 12:19:52 +0000
Subject: Re: [PATCH v7 13/41] mm: Make pte_mkwrite() take a VMA
Message-Id: <ZACUaN0NRNXMwkT2@zn.tnic>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230227222957.24501-1-rick.p.edgecombe@intel.com>
 <20230227222957.24501-14-rick.p.edgecombe@intel.com>
In-Reply-To: <20230227222957.24501-14-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: x86@kernel.org, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H . J . Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, Weijiang Yang <weijiang.yang@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, John Allen <john.allen@amd.com>, kcc@google.com, eranian@google.com, rppt@kernel.org, jamorris@linux.microsoft.com, dethoma@microsoft.com, akpm@linux-foundation.org, Andrew.Cooper3@citrix.com, christina.schimpe@intel.com, david@redhat.com, debug@rivosinc.com, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, Michal Simek <monstr@monstr.eu>, Dinh Nguyen <dinguyen@kernel.org>, linux-mips@vger.kernel.org, linux-openrisc@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, xen-devel@lists.xenproject.org

On Mon, Feb 27, 2023 at 02:29:29PM -0800, Rick Edgecombe wrote:
> [0] https://lore.kernel.org/lkml/0e29a2d0-08d8-bcd6-ff26-4bea0e4037b0@redhat.com/#t

I guess that sub-thread about how you arrived at this "pass a VMA"
decision should be in the Link tag. But that's for the committer, I'd
say.

Thx.

-- 
Regards/Gruss,
    Boris.

https://people.kernel.org/tglx/notes-about-netiquette
