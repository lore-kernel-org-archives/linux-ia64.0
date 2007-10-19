From: Denys Vlasenko <vda.linux@googlemail.com>
Date: Fri, 19 Oct 2007 10:33:49 +0000
Subject: Re: [PATCH] ia64: check-segrel.lds vs --build-id
Message-Id: <200710191133.49970.vda.linux@googlemail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071018195453.A34D64D04E2@magilla.localdomain>
In-Reply-To: <20071018195453.A34D64D04E2@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Doug Chapman <dchapman@redhat.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thursday 18 October 2007 20:54, Roland McGrath wrote:
> Some versions of ld with --build-id support will crash when using the flag
> with a linker script that discards notes.  This bites ia64's check-segrel.lds.
> The bug is easy to avoid.

It's fixed in newer ld (not released yet IIRC), but why
are we shooting ourself in the foot by adding --build-id,
and then suffering from --build-id related problems?
--
vda
