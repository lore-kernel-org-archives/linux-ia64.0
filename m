From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 22 Nov 2004 22:27:07 +0000
Subject: Re: deferred rss update instead of sloppy rss
Message-Id: <Pine.LNX.4.58.0411221424580.22895@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>
 <Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0411221419440.20993@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0411221419440.20993@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 22 Nov 2004, Linus Torvalds wrote:

> The alternative is to just add a simple list into the task_struct and the
> head of it into mm_struct. Then, at fork, you just finish the fork() with
>
> 	list_add(p->mm_list, p->mm->thread_list);
>
> and do the proper list_del() in exit_mm() or wherever.
>
> You'll still loop in /proc, but you'll do the minimal loop necessary.

I think the approach that I posted is simpler unless there are other
benefits to be gained if it would be easy to figure out which tasks use an
mm.

