From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 23 May 2003 22:04:07 +0000
Subject: [Linux-ia64] Re: [PATCH] 2.5 - Another user stack size patch
Message-Id: <marc-linux-ia64-105590723706021@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 23 May 2003 14:15:55 -0400, Martin Hicks <mort@wildopensource.com> said:

  Martin> I hope this user stack size patch is better.

It's better, yes.

  Martin> This one places the RBS based on the max size of the stack.
  Martin> The max size of the user stack is 1TB.

vmareas may not cross region-boundaries.  We set:

# define STACK_TOP	(0x6000000000000000UL + (1UL << (4*PAGE_SHIFT - 12)) - PAGE_SIZE)

so the hard limit on the stack size if (1UL << (4*PAGE_SHIFT - 12)) -
PAGE_SIZE).  I suggest we add:

# define MAX_USER_STACK_SIZE	(1UL << (4*PAGE_SHIFT - 12)) - PAGE_SIZE)
# define STACK_TOP		(0x6000000000000000UL + MAX_USER_STACK_SIZE)

I'm not sure it's a good idea to recalculate the RBS starting address
everything IA64_RBS_BOT is used.  I suspect we should add an rbs_bot
member to the thread-data structure instead (similar to the
start_stack member in the task_struct).  Otherwise, I worry about
getting inconsistencies when RLIMIT_STACK is changed after the
bspstore value has been selected (no, there is probably no issue at
the moment, but I bet it would come around to haunt us in the future).

The rest of the patch looks OK to me (watch your formatting though:
please follow the style of the file you're modifying and use tabs
instead of blanks).  Also, I don't think there is any point declaring

	--david

