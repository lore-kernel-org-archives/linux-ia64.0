From: Rik van Riel <riel@redhat.com>
Date: Wed, 09 Jan 2013 18:32:57 +0000
Subject: Re: [PATCH 5/8] mm: use vm_unmapped_area() in hugetlbfs on ia64 architecture
Message-Id: <50EDB7D9.8000403@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1357694895-520-1-git-send-email-walken@google.com> <1357694895-520-6-git-send-email-walken@google.com>
In-Reply-To: <1357694895-520-6-git-send-email-walken@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michel Lespinasse <walken@google.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Matt Turner <mattst88@gmail.com>, David Howells <dhowells@redhat.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

On 01/08/2013 08:28 PM, Michel Lespinasse wrote:
> Update the ia64 hugetlb_get_unmapped_area function to make use of
> vm_unmapped_area() instead of implementing a brute force search.
>
> Signed-off-by: Michel Lespinasse <walken@google.com>

Acked-by: Rik van Riel <riel@redhat.com>

