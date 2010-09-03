From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 03 Sep 2010 14:35:23 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <201009031635.25093.ptesarik@suse.cz>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_teQgMfQtXYYF/qY"
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz> <AANLkTimCOWvBs1pdWeMZD9DR=u2ioFPXt7Jja73VQaZn@mail.gmail.com> <201009031104.38433.ptesarik@suse.cz>
In-Reply-To: <201009031104.38433.ptesarik@suse.cz>
To: Tony Luck <tony.luck@intel.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

--Boundary-00=_teQgMfQtXYYF/qY
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Friday 03 of September 2010 11:04:37 Petr Tesarik wrote:
> [...]
> I'm now trying to modify the lock primitives:
>
> 1. replace the fetchadd4.acq with looping over cmpxchg

I did this and I feel dumber than ever. Basically, I replaced this snippet:

	ticket = ia64_fetchadd(1, p, acq);

with:

	int	tmp;
	do {
		ticket = ACCESS_ONCE(lock->lock);
		asm volatile (
			"mov ar.ccv=%1\n"
			"add %0=1,%1;;\n"
			"cmpxchg4.acq %0=[%2],%0,ar.ccv\n"
			: "=r" (tmp)
			: "r" (ticket), "r" (&lock->lock)
			: "ar.ccv");
	} while (tmp != ticket);

Just to make sure I didn't miss something, this compiled to:

0xa0000001008dacb0: [MMI]       nop.m 0x0
0xa0000001008dacb1:             ld4.acq r15=[r32]
0xa0000001008dacb2:             nop.i 0x0;;
0xa0000001008dacc0: [MII]       mov.m ar.ccv=r15
0xa0000001008dacc1:             adds r14=1,r15;;
0xa0000001008dacc2:             nop.i 0x0
0xa0000001008dacd0: [MII]       cmpxchg4.acq r14=[r32],r14,ar.ccv
0xa0000001008dacd1:             nop.i 0x0
0xa0000001008dacd2:             nop.i 0x0;;
0xa0000001008dace0: [MIB]       nop.m 0x0
0xa0000001008dace1:             cmp4.eq p7,p6=r14,r15
0xa0000001008dace2:       (p06) br.cond.dptk.few 0xa0000001008dacb0

My test module recorded the following sequence on the failing CPU:

  }, {
    ip = 0xa00000010012f7b0,
    addr = 0xe000000181925c08,
    oldvalue = 0xffff0000,
    newvalue = 0x0,
    task = 0xe000000186930000
  }, {
    ip = 0xa0000001008dacd0,
    addr = 0xe000000181925c08,
    oldvalue = 0x0,
    newvalue = 0x0,
    task = 0xe000000186930000
  }, {
    ip = 0xa0000001008dacd0,
    addr = 0xe000000181925c08,
    oldvalue = 0x1,
    newvalue = 0x0,
    task = 0xe000000186930000
  }, {
    ip = 0xa0000001008dacd0,
    addr = 0xe000000181925c08,
    oldvalue = 0x1,
    newvalue = 0x0,
    task = 0xe000000186930000
  }, {
    ip = 0xa0000001008dacd0,
    addr = 0xe000000181925c08,
    oldvalue = 0x0,
    newvalue = 0x0,
    task = 0xe000000186930000
  }, {
    ip = 0xa0000001008dacd0,
    addr = 0xe000000181925c08,
    oldvalue = 0x1,
    newvalue = 0x1,
    task = 0xe000000186930000
  }, {

I didn't see values around zero on any other CPU in the system. So, either 
there is something seriously broken in hardware, or I made a silly mistake in 
the monitoring code.

I'm attaching my SystemTap script. I know it's hacky, but it worked for me.

Oh, I had to make two modification to the running kernel:

1. in ia64_fault()
By default the value of cr.ifa is not passed to the die notifiers, so I 
(mis)used the ar_ssd field to store the ifa before calling notify_die() for 
the debug faults.

2. in ivt.S
On all interrupt entries I added code similar to this (just using different 
registers if appropriate):

	movl r3 = (1 << 24)
	mov r15 = psr
	;;
	or  r3 = r3,r15
	;;
	mov psr.l = r3
	;;
	srlz.d
	;;

Am I blind and did I do something obviously wrong?

Petr Tesarik

--Boundary-00=_teQgMfQtXYYF/qY
Content-Type: text/x-csrc;
  charset="iso 8859-15";
  name="watchlock.stp"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="watchlock.stp"

/* Watch the spin lock for changes */

%{
#include <linux/kdebug.h>
#include <asm/kregs.h>
#include <asm/hw_irq.h>
%}

%{
static void
init_and_panic(const char *msg)
{
	unsigned int cpu, self_cpu;
	self_cpu = smp_processor_id();
	for_each_online_cpu(cpu)
		if (cpu != self_cpu)
			platform_send_ipi(cpu, 0, IA64_IPI_DM_INIT, 0);

	panic(msg);
}

static inline unsigned long
get_siglock(unsigned long addr)
{
	unsigned long ret;

	asm volatile ("ld4.acq %0=[%1]\n" : "=r" (ret) : "r" (addr));
	return ret;
}

struct fault_info {
	unsigned long ip, addr;
	unsigned long oldvalue, newvalue;
	struct task_struct *task;
};

#define DBR_COUNT	4

static DEFINE_SPINLOCK(dbr_lock);
static unsigned long dbr[DBR_COUNT];

#define HISTORY_SIZE	256

static DEFINE_PER_CPU(struct fault_info[HISTORY_SIZE], siglock_history);
static DEFINE_PER_CPU(unsigned int, siglock_history_idx);

static unsigned long
record_oldsiglock(struct pt_regs *regs, unsigned long addr)
{
	unsigned int *idx = &get_cpu_var(siglock_history_idx);
	struct fault_info *info = &get_cpu_var(siglock_history)[*idx];
	unsigned long oldval;

	info->ip = regs->cr_iip;
	info->addr = addr;
	info->oldvalue = oldval = get_siglock(info->addr);
	info->task = current;

	put_cpu_var(siglock_history);
	*idx = (*idx + 1) % HISTORY_SIZE;
	put_cpu_var(siglock_history_idx);

	return oldval;
}

static unsigned long
record_newsiglock(struct pt_regs *regs)
{
	unsigned int idx = (get_cpu_var(siglock_history_idx) - 1) % HISTORY_SIZE;
	struct fault_info *info = &get_cpu_var(siglock_history)[idx];
	unsigned long newval;

	BUG_ON(info->task != current);
	info->newvalue = newval = get_siglock(info->addr);

	put_cpu_var(siglock_history);
	put_cpu_var(siglock_history_idx);

	return newval;
}

#define TICKET_SHIFT    17
#define TICKET_BITS     15
#define TICKET_MASK     ((1 << TICKET_BITS) - 1)

static int
goes_wrong(void)
{
	unsigned int previdx;
	struct fault_info *info;
	long prevhead, curhead;
	long prevtail, curtail;

	previdx = (get_cpu_var(siglock_history_idx) - 1) % HISTORY_SIZE;
	put_cpu_var(siglock_history_idx);

	info = get_cpu_var(siglock_history);
	prevhead = info[previdx].oldvalue & TICKET_MASK;
	curhead = info[previdx].newvalue & TICKET_MASK;
	prevtail = (info[previdx].oldvalue >> TICKET_SHIFT) & TICKET_MASK;
	curtail = (info[previdx].newvalue >> TICKET_SHIFT) & TICKET_MASK;
	put_cpu_var(siglock_history);

	if (curtail == prevtail &&
	    (((curhead - prevhead) & TICKET_MASK) == 0 ||
	     ((curhead - prevhead) & TICKET_MASK) >= (1 << 14)))
		return 1;

	return 0;
}

static unsigned long
get_gr(struct pt_regs *regs, int num)
{
	switch(num) {
	case 1:
		return regs->r1;
	case 2 ... 3:
		return (&regs->r2)[num - 2];
	case 4:
		{
			register unsigned long r4 asm("r4");
			return r4;
		}
	case 5:
		{
			register unsigned long r5 asm("r5");
			return r5;
		}
	case 6:
		{
			register unsigned long r6 asm("r6");
			return r6;
		}
	case 7:
		{
			register unsigned long r7 asm("r7");
			return r7;
		}
	case 8 ... 11:
		return (&regs->r8)[num - 8];
	case 12 ... 13:
	case 15:
		return (&regs->r12)[num - 12];
	case 14:
		return regs->r14;
	case 16 ... 31:
		return (&regs->r16)[num - 16];
	case 32 ... 127:
		/* Too lazy to write code to access the backing store.
		   Just let debug_notify() ignore this access */
		return regs->ar_ccv ^ 1;
	default:
		BUG();
	}
}

static int
should_modify(struct pt_regs *regs)
{
	unsigned long opcode;
	long regnum;

	/* Check if this is a cmpxchg4 instruction */
	/* This is a HACK and only works for our special case */
	opcode = *(unsigned long*)regs->cr_iip;
	if ((opcode & 0x3fd900000003UL) != 0x101100000001UL)
		return 1;

	/* Extract the target register number */
	regnum = (opcode >> 11) & 0x7f;

	/* Check whether the compare was successful (the register
	   value is equal to ar.ccv */
	return get_gr(regs, regnum) == regs->ar_ccv;
}

static int
debug_notify(struct notifier_block *self, unsigned long val, void *data)
{
	struct die_args *args = (struct die_args *)data;
	struct pt_regs *regs = args->regs;
	unsigned long vector = args->err;
	unsigned long lockaddr = regs->ar_ssd & ~0x3UL;

	if (val != DIE_FAULT)
		return NOTIFY_DONE;

	if (vector == 29) {
		unsigned long siglock_value =
			record_oldsiglock(regs, lockaddr);

		if ((siglock_value & ~1ULL) == 0x40000)
			init_and_panic("Spinlock corrupted already!");

		regs->cr_ipsr |= IA64_PSR_DD | IA64_PSR_SS;
		return NOTIFY_STOP;
	} else if (vector == 36) {
		unsigned long siglock_value = record_newsiglock(regs);

		if (should_modify(regs) && goes_wrong())
			init_and_panic("Spinlock goes wrong!");
		if ((siglock_value & ~1ULL) == 0x40000)
			init_and_panic("Caught the corruption!");

		regs->cr_ipsr &= ~IA64_PSR_SS;
		return NOTIFY_STOP;
	}

	return NOTIFY_DONE;
}

static struct notifier_block debug_notifier = {
	.notifier_call = debug_notify,
	.priority = 0x7ffffffe
};

%}

%{
static void
load_dbr(void *dummy)
{
	unsigned long defmask = (((1UL << 56) - 1) & ~0x3ULL) +
		(0xfUL << 56) +	/* enable in all privilege levels */
		(1UL << 62);	/* trigger on write */
	int i;

	for (i = 0; i < DBR_COUNT; ++i) {
		unsigned long mask = dbr[i] ? defmask : 0UL;

		asm volatile (
			"mov dbr[%0]=%1;;\n"
			"mov dbr[%2]=%3;;\n"
			: : "r" (2*i), "r" (dbr[i]), "r" (2*i+1), "r" (mask));
	}
	asm volatile("srlz.d;;");
}
%}

function enable_debug ()
%{
	load_dbr(NULL);
	CONTEXT->regs->cr_ipsr |= IA64_PSR_DB;
%}

function disable_debug ()
%{
	unsigned long flags;
	int i;

	for (i = 0; i < DBR_COUNT; ++i) {
		asm volatile (
			"mov dbr[%0]=%1;;\n"
			"mov dbr[%2]=%3;;\n"
			: : "r" (2*i), "r" (0UL), "r" (2*i+1), "r" (0UL));
	}
	asm volatile("srlz.d;;");

	CONTEXT->regs->cr_ipsr &= ~IA64_PSR_DB;
%}

function try_add_debug (sighand:long)
%{
	struct sighand_struct *sighand =
		(struct sighand_struct*)THIS->sighand;
	unsigned long lockaddr = (unsigned long) &sighand->siglock;
	unsigned long flags;
	int i, freeslot;

	spin_lock_irqsave(&dbr_lock, flags);

	freeslot = -1;
	for (i = 0; i < DBR_COUNT; ++i) {
		if (dbr[i] == lockaddr)
			break;
		if (!dbr[i] && freeslot < 0)
			freeslot = i;
	}
	if (i == DBR_COUNT && freeslot >= 0) {
		dbr[freeslot] = lockaddr;
		smp_call_function(load_dbr, NULL, 0);
	}

	spin_unlock_irqrestore(&dbr_lock, flags);
%}

function try_remove_debug (sighand:long)
%{
	struct sighand_struct *sighand =
		(struct sighand_struct*)THIS->sighand;
	unsigned long lockaddr = (unsigned long) &sighand->siglock;
	unsigned long flags;
	int i;

	/* Racy, but best we can get :( */
	if (atomic_read(&sighand->count) > 1)
		return;

	spin_lock_irqsave(&dbr_lock, flags);

	for (i = 0; i < DBR_COUNT; ++i) {
		if (dbr[i] == lockaddr)
			dbr[i] = 0;
	}

	spin_unlock_irqrestore(&dbr_lock, flags);
%}

probe syscall.*
{
	enable_debug();
}

#if 0
probe syscall.*.return
{
	disable_debug();
}
#endif

probe kernel.function("schedule").return
{
	enable_debug ();
}

function is_our_task (task:long)
%{
	struct task_struct *tsk = (struct task_struct*)THIS->task;
        THIS->__retvalue = !IS_ERR(tsk) && !strcmp(tsk->comm, "count");
%}

probe kernel.function("copy_process").return
{
	if (is_our_task($return))
		try_add_debug($return->sighand);
}

probe kernel.function("__cleanup_sighand")
{
	try_remove_debug($sighand);
}

function setup_watch ()
%{
	register_die_notifier(&debug_notifier);
%}

function remove_watch ()
%{
	memset(dbr, sizeof dbr, 0);
	smp_call_function(load_dbr, NULL, 0);
	unregister_die_notifier(&debug_notifier);
%}

probe begin
{
	setup_watch();
}

probe end, error
{
	remove_watch();
}

--Boundary-00=_teQgMfQtXYYF/qY--
