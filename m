From: Matthew Wilcox <willy@infradead.org>
Date: Mon, 11 Jun 2018 17:18:11 +0000
Subject: Re: perfmon trouble
Message-Id: <20180611171811.GB28292@bombadil.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180608184842.GD30522@ZenIV.linux.org.uk>
 <CA+55aFz9cS3m=wZxqKbzrCLEjhPoPddKw5U2MDKNqbG79Wx6bw@mail.gmail.com>
 <20180609051051.GF30522@ZenIV.linux.org.uk>
 <20180609155107.GH30522@ZenIV.linux.org.uk>
 <20180611021028.GT30522@ZenIV.linux.org.uk>
 <20180611162313.GA6942@infradead.org>
 <20180611164859.GA28292@bombadil.infradead.org>
 <CA+55aFykGPDTVN=UvrcDvwV3S_sixXREu8D7eK+x695OmA2PNw@mail.gmail.com>
In-Reply-To: <CA+55aFykGPDTVN=UvrcDvwV3S_sixXREu8D7eK+x695OmA2PNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Stephane Eranian <eranian@google.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Mon, Jun 11, 2018 at 10:04:00AM -0700, Linus Torvalds wrote:
> On Mon, Jun 11, 2018 at 9:49 AM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > The problem is that even oprofile on ia64 depends on perfmon.
> 
> Hmm? You can definitely enable ia64 support for oprofile even without perfmon.

Oh, I think my memory is playing tricks on me.  This is my confusion, I think:

oprofile-$(CONFIG_PERFMON) += perfmon.o

so perfmon events are exposed through oprofile, but you can disable
perfmon without disabling oprofile.

> Because I'd be inclined to just remove CONFIG_PERFMON support, and see
> if anybody even notices..
> 
> I'm not expecting a lot of people to do a lot of oprofile on ia64
> anyway. It's a bit late to start optimizing things now.
> 
> Do people use perfmon still? Maybe. Maybe not. Perhaps we could just
> mark it as broken in the Kconfig file for now, and see if somebody
> says something?

That gets my vote.

Tony?  Fenghua?

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 792437d526c6..ff861420b8f5 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -455,6 +455,7 @@ config IA64_MCA_RECOVERY
 
 config PERFMON
        bool "Performance monitor support"
+       depends on BROKEN
        help
          Selects whether support for the IA-64 performance monitor hardware
          is included in the kernel.  This makes some kernel data-structures a

