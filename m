From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Mon, 11 Jun 2018 20:06:01 +0000
Subject: Re: perfmon trouble
Message-Id: <20180611200601.GW30522@ZenIV.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180608184842.GD30522@ZenIV.linux.org.uk>
 <CA+55aFz9cS3m=wZxqKbzrCLEjhPoPddKw5U2MDKNqbG79Wx6bw@mail.gmail.com>
 <20180609051051.GF30522@ZenIV.linux.org.uk>
 <20180609155107.GH30522@ZenIV.linux.org.uk>
 <20180611021028.GT30522@ZenIV.linux.org.uk>
 <20180611162313.GA6942@infradead.org>
 <20180611164859.GA28292@bombadil.infradead.org>
 <CA+55aFykGPDTVN=UvrcDvwV3S_sixXREu8D7eK+x695OmA2PNw@mail.gmail.com>
 <20180611171811.GB28292@bombadil.infradead.org>
 <CABPqkBTwqtFxtFsCjTNyHa_T1_vCbCQWHwo42RZAbg0QRi1BFw@mail.gmail.com>
In-Reply-To: <CABPqkBTwqtFxtFsCjTNyHa_T1_vCbCQWHwo42RZAbg0QRi1BFw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephane Eranian <eranian@google.com>
Cc: willy@infradead.org, Linus Torvalds <torvalds@linux-foundation.org>, hch@infradead.org, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Mon, Jun 11, 2018 at 11:51:34AM -0700, Stephane Eranian wrote:

> Thanks Al for the careful analysis. If I understand correctly, the
> problem seems to be that on
> execve the mapping of the sampling buffer is not destroyed and then on
> close, the kernel
> unmaps whatever the new binary had in that address range. The fix
> would be to ensure
> the mmap is destroyed on execve.

mmap *is* destroyed on execve; it's just that perfmon doesn't notice and
then tries to destroy it again on close, nevermind that it's a different
process, different mapping, etc.

> My problem is that I do not have IA64 hw anymore, so whatever the fix,
> I will not be able
> to test this. In the meantime, I agree with Matthew, simply disable
> PERFMON support.

Out of curiosity - what happened to never-went-into-mainline rewrite
of perfmon circa 2008?  perfmon2 sourceforget site has a collection
of those, up to 2.6.29; AFAICS, they did have a somewhat saner syscall
interface (no auto-mmap on creation, no auto-munmap attempts on close).
By this point it obviously would've been too late to resurrect anyway,
but I wonder what happened with it...
