From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Wed, 16 Oct 2019 08:28:30 +0000
Subject: Re: [PATCH v2 00/29] vmlinux.lds.h: Refactor EXCEPTION_TABLE and NOTES
Message-Id: <20191016082830.GC4267@osiris>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191011000609.29728-1-keescook@chromium.org>
In-Reply-To: <20191011000609.29728-1-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: Borislav Petkov <bp@alien8.de>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Michael Ellerman <mpe@ellerman.id.au>, Will Deacon <will@kernel.org>, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 10, 2019 at 05:05:40PM -0700, Kees Cook wrote:
> Arch maintainers: please send Acks (if you haven't already) for your
> respective linker script changes; the intention is for this series to
> land via -tip.
> 
> v1: https://lore.kernel.org/lkml/20190926175602.33098-1-keescook@chromium.org
> v2: clean up commit messages, rename RO_EXCEPTION_TABLE (bp)
> 
> 
> This series works to move the linker sections for NOTES and
> EXCEPTION_TABLE into the RO_DATA area, where they belong on most
> (all?) architectures. The problem being addressed was the discovery
> by Rick Edgecombe that the exception table was accidentally marked
> executable while he was developing his execute-only-memory series. When
> permissions were flipped from readable-and-executable to only-executable,
> the exception table became unreadable, causing things to explode rather
> badly. :)

Feel free to add
Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
to every patch in this series which touches s390.
