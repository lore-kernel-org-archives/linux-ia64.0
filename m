From: Rik van Riel <riel@redhat.com>
Date: Wed, 09 Jan 2013 20:57:09 +0000
Subject: Re: [PATCH 6/8] mm: remove free_area_cache use in powerpc architecture
Message-Id: <50EDD9A5.8060404@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1357694895-520-1-git-send-email-walken@google.com> <1357694895-520-7-git-send-email-walken@google.com>
In-Reply-To: <1357694895-520-7-git-send-email-walken@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michel Lespinasse <walken@google.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Matt Turner <mattst88@gmail.com>, David Howells <dhowells@redhat.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

On 01/08/2013 08:28 PM, Michel Lespinasse wrote:
> As all other architectures have been converted to use vm_unmapped_area(),
> we are about to retire the free_area_cache.
>
> This change simply removes the use of that cache in
> slice_get_unmapped_area(), which will most certainly have a
> performance cost. Next one will convert that function to use the
> vm_unmapped_area() infrastructure and regain the performance.
>
> Signed-off-by: Michel Lespinasse <walken@google.com>

Acked-by: Rik van Riel <riel@redhat.com>

