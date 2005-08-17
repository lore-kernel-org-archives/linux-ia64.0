From: david mosberger <dmosberger@gmail.com>
Date: Wed, 17 Aug 2005 01:30:09 +0000
Subject: Re: [PATCH] Fix gcc 4 warnings on ia64
Message-Id: <ed5aea43050816183044205495@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050816155747.GN20749@wotan.suse.de>
In-Reply-To: <20050816155747.GN20749@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 8/16/05, Andi Kleen <ak@suse.de> wrote:

> And for an inline __attribute__((const)) is a nop because the compiler
> always looks at the code inside the inline and decides based
> on that if the return value is constant or not.

Not if the function contains an "asm", which is what used to be there.
 It later got changed to reading a global, so I agree that the
__attribute_const__ is no longer necessary.

  --david
-- 
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
