From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 04 Sep 2004 16:55:16 +0000
Subject: Re: [PATCH 2/4] SGI Altix cross partition functionality (1st revision)
Message-Id: <20040904175516.A16490@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163514.GB27891@sgi.com>
In-Reply-To: <20040616163514.GB27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Sep 04, 2004 at 11:35:11AM -0500, Russ Anderson wrote:
> Perhaps I'm missing what you mean by "complexity".  I understand that a reasonable
> way to modify a mono-CPU kernel to run on a dual-CPU system is to add a big
> kernel lock.  And that as the number of CPUs increase, the locks need to be
> finer grain to avoid excessive lock contention.  And that identifying and
> breaking up the hot locks is a part of that process.  Cray went through
> that process with COS, unicos, SGI with Irix, and now the community
> with Linux.
> 
> What Dean is doing, and what the Cray and SGI people have learned over
> the last couple decades of hard work, is that it is simpler and less complex 
> to design in fine grain locks to avoid scaling problems.  We know that CPUs 
> will get faster, the number of CPUs will increase, as will the number of nodes 
> and amount of memory.  And as they increase, we know that big locks will get 
> hot and need to broken up.  So that is why you will find people that
> believe that it is simpler and less complex to design in fine grain locks,
> to avoid having to track down and fix scaling bugs.  

Have you not looked at the code or are you publically trying to make a fool
of yourself?

The lock is taken during xfc_connect/disconnect which happen exactly at
ifconfig up/down time.  Please explain me why ifconfig scalability matters
to SGI.

