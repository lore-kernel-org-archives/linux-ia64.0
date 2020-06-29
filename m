From: Pekka Enberg <penberg@gmail.com>
Date: Mon, 29 Jun 2020 14:01:14 +0000
Subject: Re: [PATCH 0/8] mm: cleanup usage of <asm/pgalloc.h>
Message-Id: <CAOJsxLE47WP9aMY3nh=E7C1a_esHt=sBFWCnsVA2umZ7TZ6TTA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200627143453.31835-1-rppt@kernel.org>
In-Reply-To: <20200627143453.31835-1-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Christophe Leroy <christophe.leroy@csgroup.eu>, Joerg Roedel <joro@8bytes.org>, Max Filippov <jcmvbkbc@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Satheesh Rajendran <sathnaga@linux.vnet.ibm.com>, Stafford Horne <shorne@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Steven Rostedt <rostedt@goodmis.org>, linux-alpha@vger.kernel.org, "list@ebiederm.org:DOCUMENTATION <linux-doc@vger.kernel.org>,
        list@ebiederm.org:MEMORY MANAGEMENT <linux-mm@kvack.org>," <linux-arch@vger.kernel.org>, linux-arm-kernel <linux-arm>

On Sat, Jun 27, 2020 at 5:35 PM Mike Rapoport <rppt@kernel.org> wrote:
> Most architectures have very similar versions of pXd_alloc_one() and
> pXd_free_one() for intermediate levels of page table.
> These patches add generic versions of these functions in
> <asm-generic/pgalloc.h> and enable use of the generic functions where
> appropriate.

Very nice cleanup series to the page table code!

FWIW:

Reviewed-by: Pekka Enberg <penberg@kernel.org>
