From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 07 Jul 2004 08:32:50 +0000
Subject: Re: Using GDB kills kernel
Message-Id: <16619.46386.180554.724619@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <16610.19218.349114.463377@wombat.chubb.wattle.id.au>
In-Reply-To: <16610.19218.349114.463377@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On Wed, 7 Jul 2004 11:03:08 +1000, Peter Chubb <peterc@gelato.unsw.edu.au> said:
Peter> I'm currently trying binary chop to see what change(s) caused
Peter> the problem.  But there were a lot of them in a very tangled
Peter> revision history, so progress is slow.

David> I'd guess that it may be another bug related to moving
David> "current" for init_task to region 5.  Though it's not apparent
David> how or why this would only bite you (so far).

The problem is changeset

  roland@redhat.com[torvalds]|ChangeSet|20040624165002|30880

which changes the way PTEs are looked up for the gate page.

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
