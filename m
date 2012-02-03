From: DJ Delorie <dj@redhat.com>
Date: Fri, 03 Feb 2012 06:45:42 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <xnbopg8lex.fsf@greed.delorie.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
In-Reply-To: <20120201151918.GC16714@quack.suse.cz> (Jan Kara's message of
	"Wed, 1 Feb 2012 16:19:18 +0100")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org


Jan Kara <jack@suse.cz> writes:
>   we've spotted the following mismatch between what kernel folks expect
> from a compiler and what GCC really does, resulting in memory corruption on
> some architectures. Consider the following structure:
> struct x {
>     long a;
>     unsigned int b1;
>     unsigned int b2:1;
> };

If this structure were volatile, you could try
-fstrict-volatile-bitfields, which forces GCC to use the C type to
define the access width, instead of doing whatever it thinks is optimal.

Note: that flag is enabled by default for some targets already, most
notably ARM.
