From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 11 Jun 2018 18:59:50 +0000
Subject: Re: perfmon trouble
Message-Id: <CA+55aFyg7W8G0fdJgqWEPRu4UeRd16EnkdR2uY1A_e1j8rZUGA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180608184842.GD30522@ZenIV.linux.org.uk> <CA+55aFz9cS3m=wZxqKbzrCLEjhPoPddKw5U2MDKNqbG79Wx6bw@mail.gmail.com>
 <20180609051051.GF30522@ZenIV.linux.org.uk> <20180609155107.GH30522@ZenIV.linux.org.uk>
 <20180611021028.GT30522@ZenIV.linux.org.uk> <20180611162313.GA6942@infradead.org>
 <20180611164859.GA28292@bombadil.infradead.org> <CA+55aFykGPDTVN=UvrcDvwV3S_sixXREu8D7eK+x695OmA2PNw@mail.gmail.com>
 <20180611171811.GB28292@bombadil.infradead.org> <CABPqkBTwqtFxtFsCjTNyHa_T1_vCbCQWHwo42RZAbg0QRi1BFw@mail.gmail.com>
In-Reply-To: <CABPqkBTwqtFxtFsCjTNyHa_T1_vCbCQWHwo42RZAbg0QRi1BFw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stephane Eranian <eranian@google.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Mon, Jun 11, 2018 at 11:51 AM Stephane Eranian <eranian@google.com> wrote:
>
> In the meantime, I agree with Matthew, simply disable
> PERFMON support.

Ok, since everybody seems to agree on that, I marked it BROKEN for
now, in the hope that nobody even notices and we can just remove the
code entirely.

And if somebody *does* notice, at least we would also have a
sucker^Wtester for any possible patches to fix it.

               Linus
