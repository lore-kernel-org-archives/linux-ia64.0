From: stefan <stefan@lkcc.org>
Date: Tue, 25 Sep 2001 19:35:12 +0000
Subject: [Linux-ia64] use of setcontext()/getcontext()
Message-Id: <marc-linux-ia64-105590698805251@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello list,

  I wonder if the above function set can be used to implement something
like what is used to work on other types of machines with
setjmp()/longjmp(). I would like to continue a program at a certain point
of execution with a saved environment. I achieved this by now by the
following algorithm and want to ask if there is any better way.

static __cont_done = 0;

make_continuation {
        __cont_done = 0
	getcontext(ctx)
        if (__cont_done) goto __continuation
	save_both_stacks() // register and normal stack in heap
	return

__continuation:
	return
}

run_continuation {
	restore_both_stacks() // register and normal stack from heap
	__cont_done = 1
	setcontext(ctx)
}

I do not like the static __cont_done in the piece of code. But I do not
know how to determine if the instruction behind the getcontext() call is
due to a normal call to make_continuation() or due to the setcontext() of
run_continuation(). The setjmp() does return something appropiate but I do
not know how to do it with setcontext()/getcontext().
  
Thanks in advance,
	stefan@lkcc.org


