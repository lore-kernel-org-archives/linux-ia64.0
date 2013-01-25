From: Michael Cree <mcree@orcon.net.nz>
Date: Fri, 25 Jan 2013 03:49:58 +0000
Subject: Re: [PATCH 2/8] mm: use vm_unmapped_area() on alpha architecture
Message-Id: <43E02291-8F84-40CD-B429-847E7533EA18@orcon.net.nz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1357694895-520-1-git-send-email-walken@google.com> <1357694895-520-3-git-send-email-walken@google.com>
In-Reply-To: <1357694895-520-3-git-send-email-walken@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Matt Turner <mattst88@gmail.com>, David Howells <dhowells@redhat.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

On 9/01/2013, at 2:28 PM, Michel Lespinasse wrote:
> Update the alpha arch_get_unmapped_area function to make use of
> vm_unmapped_area() instead of implementing a brute force search.
>
> Signed-off-by: Michel Lespinasse <walken@google.com>

'Tis running fine on my alpha.

Tested-by: Michael Cree <mcree@orcon.net.nz>

Cheers
Michael.

