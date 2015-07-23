From: Ralf Baechle <ralf@linux-mips.org>
Date: Thu, 23 Jul 2015 06:58:31 +0000
Subject: Re: [PATCH V4 2/6] mm: mlock: Add new mlock, munlock, and munlockall system calls
Message-Id: <20150723065830.GA5919@linux-mips.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
 <1437508781-28655-3-git-send-email-emunson@akamai.com>
 <20150721134441.d69e4e1099bd43e56835b3c5@linux-foundation.org>
 <1437528316.16792.7.camel@ellerman.id.au>
 <20150722141501.GA3203@akamai.com>
In-Reply-To: <20150722141501.GA3203@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric B Munson <emunson@akamai.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mips@linux-mips.org, linux-m68k@vger.kernel.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, linux-am33-list@redhat.com, Geert Uytterhoeven <geert@linux-m68k.org>, Vlastimil Babka <vbabka@suse.cz>, Guenter Roeck <linux@roeck-us.net>, linux-xtensa@linux-xtensa.org, linux-s390@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-parisc@vger.kernel.orglin

On Wed, Jul 22, 2015 at 10:15:01AM -0400, Eric B Munson wrote:

> > 
> > You haven't wired it up properly on powerpc, but I haven't mentioned it because
> > I'd rather we did it.
> > 
> > cheers
> 
> It looks like I will be spinning a V5, so I will drop all but the x86
> system calls additions in that version.

The MIPS bits are looking good however, so

Acked-by: Ralf Baechle <ralf@linux-mips.org>

With my ack, will you keep them or maybe carry them as a separate patch?

Cheers,

  Ralf
