From: Christian Brauner <brauner@kernel.org>
Date: Tue, 30 Aug 2022 15:56:22 +0000
Subject: Re: [RFC PATCH 2/2] fs/xattr: wire up syscalls
Message-Id: <20220830155622.4hcj6dka5jswydrg@wittgenstein>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220830152858.14866-1-cgzones@googlemail.com>
In-Reply-To: <20220830152858.14866-1-cgzones@googlemail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christian =?utf-8?B?R8O2dHRzY2hl?= <cgzones@googlemail.com>
Cc: selinux@vger.kernel.org, Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Eric Paris <eparis@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Suren Baghdasaryan <surenb@google.com>, =?utf-8?B?QW5kcsOp?= Almeida <andrealmeid@igalia.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Guo Ren <guoren@kernel.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Wang Haojun <jiangliuer01@gmail.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-fsdevel@vger.kernel.org, linux-audit@redhat.com, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On Tue, Aug 30, 2022 at 05:28:38PM +0200, Christian Göttsche wrote:
> Enable the new added extended attribute related syscalls.
> 
> Signed-off-by: Christian Göttsche <cgzones@googlemail.com>
> ---

Fwiw, I think a while ago it was pointed out that for most syscall
additions you can just fold the hookup patch in. It probably also
wouldn't hurt to trim that Cc list significantly down to mostly the
lists...
