From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Sat, 20 May 2023 19:22:44 +0000
Subject: Re: [crosspost] dropping support for ia64
Message-Id: <ff58a3e76e5102c94bb5946d99187b358def688a.camel@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAMj1kXFCMh_578jniKpUtx_j8ByHnt=s7S+yQ+vGbKt9ud7+kQ@mail.gmail.com>
In-Reply-To: <CAMj1kXFCMh_578jniKpUtx_j8ByHnt=s7S+yQ+vGbKt9ud7+kQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello!

On Sat, 2023-05-20 at 18:48 +0200, Florian Weimer wrote:
> * matoro:
> 
> > There is no user-mode emulation for ia64 in QEMU either.  The only 
> > "ongoing" emulation work is Sergei's fork of the old "ski" emulator, but 
> > this is far from QEMU quality or even usable yet:  
> > https://github.com/trofi/ski
> 
> Yeah, I must have misremembered.  Awkward.
> 
> So it's a really exclusive club, which makes continued maintenance
> efforts even more doubtful.

I have been thinking about this discussion for a while now and my suggestion
would be to drop ia64 support from the kernel, GRUB and gcc/binutils/glibc in
this order:

- Kernel: After the next LTS release
- GRUB: After the 2.12 release
- gcc/binutils/glibc: After support was dropped from the kernel

This way anyone still using ia64 will be able to use it with a supported codebase
for an extended time and upstream projects have target releases for which they
can plan the removal.

Other projects such as LLVM, OpenJDK and Ruby already support native code generation
support for ia64 although OpenJDK still works using the Zero port.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer
`. `'   Physicist
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
