From: "H . J . Lu" <hjl@valinux.com>
Date: Tue, 16 Jan 2001 01:13:45 +0000
Subject: Re: [Linux-ia64] [PATCH] Fix for kernel DRM build
Message-Id: <marc-linux-ia64-105590693005048@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205902@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205902@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jan 15, 2001 at 04:42:26PM -0800, Jim Wilson wrote:
> >     ld: drivers/char/drm/drm.o: linking 64-bit files with 32-bit
> >     files
> >     ld: drivers/char/drm/drm.o: linking constant-gp files with
> >     non-constant-gp files
> 
> I've sent a proposed patch to binutils@sources.redhat.com for comment.
> 
> I don't like HJ's proposed solution, which is to ignore the ELF header flags
> if an object file is empty.  That can mask real errors, as this ar/ld -r
> trick is not the only way to create empty object files.
> 
> My proposed patch fixes the linker to notice when the output file is empty,
> and then we set the ELF header flags from the first member of the first
> archive even though we aren't linking it in.  This fixes the kernel build

Does that work with an empty archive or an archive with files of
mixed types? I thought about your approach. But I decided against
it since it didn't work with the cases above.


H.J.

