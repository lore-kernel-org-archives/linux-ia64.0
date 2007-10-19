From: Denys Vlasenko <vda.linux@googlemail.com>
Date: Fri, 19 Oct 2007 10:28:07 +0000
Subject: Re: [PATCH] ia64 vDSO vs --build-id
Message-Id: <200710191128.08252.vda.linux@googlemail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071018221108.638644D04E2@magilla.localdomain>
In-Reply-To: <20071018221108.638644D04E2@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Roland McGrath <roland@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com, Doug Chapman <dchapman@redhat.com>

On Thursday 18 October 2007 23:11, Roland McGrath wrote:
> When gcc uses --build-id by default, the gate.lds.S linker script runs afoul
> of the new note section and produces a bad DSO image.  This fixes it.

I wonder why we bother having --build-id.
--
vda
