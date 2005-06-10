From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 10 Jun 2005 17:03:14 +0000
Subject: Re: [RFD] Separating struct task and the kernel stacks
Message-Id: <17065.51154.969389.98052@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <9712.1118384111@kao2.melbourne.sgi.com>
In-Reply-To: <9712.1118384111@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 10 Jun 2005 08:11:42 -0700 (PDT), Christoph Lameter <christoph@lameter.com> said:

  >> Switching stacks requires that struct task is copied from the
  >> original "current" to the MCA/INIT stack, then change current to
  >> point to the new stack.  Even that is not enough, there are still
  >> places that are using the old value of "current".  The main
  >> problem is the scheduler, it tracks tasks by the address of their
  >> struct task, not by the kernel stack address.  When debugging an
  >> MCA/INIT, the mismatch between the new value of current and the
  >> old task addresses in various structures can lead to some very
  >> confusing results.  The kernel is not designed to have struct
  >> task move around on the fly.

  Christoph> Could you just move the stack? Put a pointer to the stack
  Christoph> in task_info. By default this is pointing to the stack in
  Christoph> task_info. If you have to switch point it elsewhere.

Perhaps a more fruitful approach might be to treat the MCA as its own
task.  MCA are very special anyhow: they can happen at any time, even
when the kernel is supposedly non-preemptible.  Thus, running any
standard kernel code which acquires locks etc is rather dangerous.  If
you're going to do major surgery, this really needs to be thought
through first --- otherwise, we're just going to discover all the
little nasty issues piecemeal and that would be extremely painful and
cause a lot of extra work.

Also, let's be clear that we are NOT going to (de-)optimize the normal
Linux kernel based on the needs of MCA.  Proper MCA support is
important, but that needs to be accomplished without compromising the
efficiency of the normal kernel (which is where 99.99% of the time is
spent). My sense is that the MCA subsystem may have to be almost
stand-alone in order to really work reliably.

	--david
