From: Keith Owens <kaos@sgi.com>
Date: Mon, 20 Oct 2003 10:47:42 +0000
Subject: Rework arch/ia64/kernel/salinfo.c for 2.4
Message-Id: <marc-linux-ia64-106664704821234@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have reworked salinfo.c to get a clean separation between the
interrupt handler that is called from mca.c and the rest of the salinfo
code that runs in user context.

It is critical that the interrupt handler part of salinfo must never
fail or deadlock, mca.c must be allowed to continue to get decent
debugging information.  With this rework, the handler only saves the
address of the buffer, sets the event bit and calls up() on the salinfo
data semaphore then returns to mca.c.

The information that was split between salinfo_event (4), salinfo_data
(4) and salinfo_buffer (NR_CPUS*4) has been consolidated into a single
salinfo_data (4) structure.  The consolidation simplifies the code and
the locking.

Use set_cpus_allowed() instead of using IPI to read and clear SAL
records.  This does not disable interrupts and keeps the clean
separation between interrupt and user context.  As a bonus, this code
is ready for machines with > 64 cpus in a single system image.

The rework removes the races and deadlocks that were mentioned on this
list last week.  It also avoids multiple reads of the SAL record when
user space has to read the record in multiple chunks.  I am still
stress testing the code, this release is a request for comments.

The rework patch is larger than the source, it is easier to show the
complete code rather than a patch.


/*
 * salinfo.c
 *
 * Creates entries in /proc/sal for various system features.
 *
 * Copyright (c) 2003 Silicon Graphics, Inc.  All rights reserved.
 * Copyright (c) 2003 Hewlett-Packard Co
 *	Bjorn Helgaas <bjorn.helgaas@hp.com>
 *
 * 10/30/2001	jbarnes@sgi.com		copied much of Stephane's palinfo
 *					code to create this file
 * Oct 20 2003	kaos@sgi.com
 *   Replace IPI with set_cpus_allowed() to read a record from the required cpu.
 *   Redesign salinfo log processing to separate interrupt and user space
 *   contexts.
 *   Cache the record across multi-block reads from user space.
 *   Support > 64 cpus.
 */

#include <linux/types.h>
#include <linux/proc_fs.h>
#include <linux/module.h>
#include <linux/smp.h>
#include <linux/smp_lock.h>
#include <linux/vmalloc.h>

#include <asm/semaphore.h>
#include <asm/sal.h>
#include <asm/uaccess.h>

MODULE_AUTHOR("Jesse Barnes <jbarnes@sgi.com>");
MODULE_DESCRIPTION("/proc interface to IA-64 SAL features");
MODULE_LICENSE("GPL");

static int salinfo_read(char *page, char **start, off_t off, int count, int *eof, void *data);

typedef struct {
	const char		*name;		/* name of the proc entry */
	unsigned long           feature;        /* feature bit */
	struct proc_dir_entry	*entry;		/* registered entry (removal) */
} salinfo_entry_t;

/*
 * List {name,feature} pairs for every entry in /proc/sal/<feature>
 * that this module exports
 */
static salinfo_entry_t salinfo_entries[]={
	{ "bus_lock",           IA64_SAL_PLATFORM_FEATURE_BUS_LOCK, },
	{ "irq_redirection",	IA64_SAL_PLATFORM_FEATURE_IRQ_REDIR_HINT, },
	{ "ipi_redirection",	IA64_SAL_PLATFORM_FEATURE_IPI_REDIR_HINT, },
	{ "itc_drift",		IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT, },
};

#define NR_SALINFO_ENTRIES ARRAY_SIZE(salinfo_entries)

static char *salinfo_log_name[] = {
	"mca",
	"init",
	"cmc",
	"cpe",
};

static struct proc_dir_entry *salinfo_proc_entries[
	ARRAY_SIZE(salinfo_entries) +			/* /proc/sal/bus_lock */
	ARRAY_SIZE(salinfo_log_name) +			/* /proc/sal/{mca,...} */
	(2 * ARRAY_SIZE(salinfo_log_name)) +		/* /proc/sal/mca/{event,data} */
	1];						/* /proc/sal */

/* Allow build with or without large SSI support */
#ifdef CPU_MASK_NONE
#define SCA(x, y) set_cpus_allowed((x), &(y))
#else
#define cpumask_t unsigned long
#define SCA(x, y) set_cpus_allowed((x), (y))
#endif

/* Some records we get ourselves, some are accessed as saved data in buffers
 * that are owned by mca.c.
 */
struct salinfo_data_saved {
	u8*			buffer;
	u64			size;
	u64			id;
	int			cpu;
};

struct salinfo_data {
	volatile cpumask_t	cpu_event;	/* which cpus have outstanding events */
	struct semaphore	sem;		/* count of cpus with outstanding events (bits set in cpu_event) */
	u8			*log_buffer;
	u64			log_size;
	int			open;		/* single-open to prevent races */
	u8			type;
	u8			saved_num;	/* using a saved record? */
	u8			new_read;	/* start of a new read? */
	u8			cleared;	/* saved records have already been cleared? */
	int			cpu_read;	/* "current" cpu for reads */
	int			cpu_check;	/* next CPU to check */
	struct salinfo_data_saved data_saved[5];/* save last 5 records from mca.c, must be < 255 */
};

static struct salinfo_data salinfo_data[ARRAY_SIZE(salinfo_log_name)];

static spinlock_t data_lock, data_saved_lock;

static void
shift1_data_saved (struct salinfo_data *data, int shift)
{
	memcpy(data->data_saved+shift, data->data_saved+shift+1,
	       (ARRAY_SIZE(data->data_saved) - (shift+1)) * sizeof(data->data_saved[0]));
	memset(data->data_saved + ARRAY_SIZE(data->data_saved) - 1, 0,
	       sizeof(data->data_saved[0]));
}

/* This routine is invoked in interrupt context.  Note: mca.c enables
 * interrupts before calling this code for CMC/CPE.  MCA and INIT events are
 * not irq safe, do not call any routines that use spinlocks, they may deadlock.
 *
 * The buffer passed from mca.c points to the output from ia64_log_get. This is
 * a persistent buffer but its contents can change between the interrupt and
 * when user space processes the record.  Save the record id to identify
 * changes.
 */
void
salinfo_log_wakeup(int type, u8 *buffer, u64 size)
{
	struct salinfo_data *data = salinfo_data + type;
	struct salinfo_data_saved *data_saved;
	unsigned long flags = 0;
	int i, irqsafe = type != SAL_INFO_TYPE_MCA && type != SAL_INFO_TYPE_INIT;
	int saved_size = ARRAY_SIZE(data->data_saved);

	BUG_ON(type >= ARRAY_SIZE(salinfo_log_name));

	if (irqsafe)
		spin_lock_irqsave(&data_saved_lock, flags);
	for (i = 0, data_saved = data->data_saved; i < saved_size; ++i, ++data_saved) {
		if (!data_saved->buffer)
			break;
	}
	if (i = saved_size) {
		shift1_data_saved(data, 0);
		data_saved = data->data_saved + saved_size - 1;
	}
	data_saved->cpu = smp_processor_id();
	data_saved->id = ((sal_log_record_header_t *)buffer)->id;
	data_saved->size = size;
	data_saved->buffer = buffer;
	/* mca.c clears CMC/CPE from SAL immediately */
	data->cleared = type = SAL_INFO_TYPE_CMC || type = SAL_INFO_TYPE_CPE;
	if (irqsafe)
		spin_unlock_irqrestore(&data_saved_lock, flags);

	if (!test_and_set_bit(smp_processor_id(), &data->cpu_event)) {
		if (irqsafe)
			up(&data->sem);
	}
}

static int
salinfo_event_open(struct inode *inode, struct file *file)
{
	if (!suser())
		return -EPERM;
	return 0;
}

static ssize_t
salinfo_event_read(struct file *file, char *buffer, size_t count, loff_t *ppos)
{
	struct inode *inode = file->f_dentry->d_inode;
	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
	struct salinfo_data *data = entry->data;
	char cmd[32];
	size_t size;
	int i, n, cpu = -1;

retry:
	if (down_trylock(&data->sem)) {
		if (file->f_flags & O_NONBLOCK)
			return -EAGAIN;
		if (down_interruptible(&data->sem))
			return -ERESTARTSYS;
	}

	n = data->cpu_check;
	for (i = 0; i < NR_CPUS; i++) {
		if (test_bit(n, &data->cpu_event)) {
			cpu = n;
			break;
		}
		if (++n = NR_CPUS)
			n = 0;
	}

	if (cpu = -1)
		goto retry;

	/* events are sticky until the user says "clear" */
	up(&data->sem);

	/* for next read, start checking at next CPU */
	data->cpu_check = cpu;
	if (++data->cpu_check = NR_CPUS)
		data->cpu_check = 0;

	snprintf(cmd, sizeof(cmd), "read %d\n", cpu);

	size = strlen(cmd);
	if (size > count)
		size = count;
	if (copy_to_user(buffer, cmd, size))
		return -EFAULT;

	return size;
}

static struct file_operations salinfo_event_fops = {
	.open  = salinfo_event_open,
	.read  = salinfo_event_read,
};

static int
salinfo_log_open(struct inode *inode, struct file *file)
{
	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
	struct salinfo_data *data = entry->data;

	if (!suser())
		return -EPERM;

	spin_lock(&data_lock);
	if (data->open) {
		spin_unlock(&data_lock);
		return -EBUSY;
	}
	data->open = 1;
	spin_unlock(&data_lock);

	return 0;
}

static int
salinfo_log_release(struct inode *inode, struct file *file)
{
	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
	struct salinfo_data *data = entry->data;

	vfree(data->log_buffer);
	data->log_buffer = NULL;
	spin_lock(&data_lock);
	data->open = 0;
	spin_unlock(&data_lock);
	return 0;
}

static void
call_on_cpu(int cpu, void (*fn)(void *), void *arg)
{
	cpumask_t save_cpus_allowed, new_cpus_allowed;
	memcpy(&save_cpus_allowed, &current->cpus_allowed, sizeof(save_cpus_allowed));
	memset(&new_cpus_allowed, 0, sizeof(new_cpus_allowed));
	set_bit(cpu, &new_cpus_allowed);
	SCA(current, new_cpus_allowed);
	(*fn)(arg);
	SCA(current, save_cpus_allowed);
}

static void
salinfo_log_read_cpu(void *context)
{
	struct salinfo_data *data = context;
	data->log_size = ia64_sal_get_state_info(data->type, (u64 *) data->log_buffer);
}

static void
salinfo_log_new_read(struct salinfo_data *data)
{
	struct salinfo_data_saved *data_saved;
	unsigned long flags;
	int i;
	int saved_size = ARRAY_SIZE(data->data_saved);

	data->new_read = 0;
	data->saved_num = 0;
	spin_lock_irqsave(&data_saved_lock, flags);
retry:
	for (i = 0, data_saved = data->data_saved; i < saved_size; ++i, ++data_saved) {
		if (data_saved->buffer && data_saved->cpu = data->cpu_read) {
			sal_log_record_header_t *rh = (sal_log_record_header_t *)(data_saved->buffer);
			data->log_size = data_saved->size;
			memcpy(data->log_buffer, rh, data->log_size);
			barrier();	/* id check must not be moved */
			if (rh->id = data_saved->id) {
				data->saved_num = i+1;
				break;
			}
			/* saved record changed by mca.c since interrupt, discard it */
			shift1_data_saved(data, i);
			goto retry;
		}
	}
	spin_unlock_irqrestore(&data_saved_lock, flags);

	if (!data->saved_num)
		call_on_cpu(data->cpu_read, salinfo_log_read_cpu, data);
}

static ssize_t
salinfo_log_read(struct file *file, char *buffer, size_t count, loff_t *ppos)
{
	struct inode *inode = file->f_dentry->d_inode;
	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
	struct salinfo_data *data = entry->data;
	void *saldata;
	size_t size;

	if (!data->log_buffer) {
		data->log_buffer = vmalloc(ia64_sal_get_state_info_size(data->type));
		if (!data->log_buffer)
			return -ENOMEM;
	}

	if (data->new_read)
		salinfo_log_new_read(data);
	if (*ppos >= data->log_size)
		return 0;

	saldata = data->log_buffer + file->f_pos;
	size = data->log_size - file->f_pos;
	if (size > count)
		size = count;
	if (copy_to_user(buffer, saldata, size))
		return -EFAULT;

	*ppos += size;
	return size;
}

static void
salinfo_log_clear_cpu(void *context)
{
	struct salinfo_data *data = context;
	ia64_sal_clear_state_info(data->type);
}

static int
salinfo_log_clear(struct salinfo_data *data, int cpu)
{
	if (!data->log_buffer) {
		data->log_buffer = vmalloc(ia64_sal_get_state_info_size(data->type));
		if (!data->log_buffer)
			return -ENOMEM;
	}
	if (!test_bit(cpu, &data->cpu_event))
		return 0;
	down(&data->sem);
	clear_bit(cpu, &data->cpu_event);
	data->log_size = 0;
	if (data->saved_num) {
		unsigned long flags;
		spin_lock_irqsave(&data_saved_lock, flags);
		shift1_data_saved(data, data->saved_num - 1 );
		data->saved_num = 0;
		spin_unlock_irqrestore(&data_saved_lock, flags);
	}
	if (!data->cleared)
		call_on_cpu(cpu, salinfo_log_clear_cpu, data);

	/* clearing a record may make a new record visible */
	data->cpu_read = cpu;
	salinfo_log_new_read(data);
	if (data->log_size &&
	    !test_and_set_bit(data->cpu_read,  &data->cpu_event))
		up(&data->sem);
	return 0;
}

static ssize_t
salinfo_log_write(struct file *file, const char *buffer, size_t count, loff_t *ppos)
{
	struct inode *inode = file->f_dentry->d_inode;
	struct proc_dir_entry *entry = (struct proc_dir_entry *) inode->u.generic_ip;
	struct salinfo_data *data = entry->data;
	char cmd[32];
	size_t size;
	int cpu;

	size = sizeof(cmd);
	if (count < size)
		size = count;
	if (copy_from_user(cmd, buffer, size))
		return -EFAULT;

	if (sscanf(cmd, "read %d", &cpu) = 1) {
		data->cpu_read = cpu;
		data->new_read = 1;
	} else if (sscanf(cmd, "clear %d", &cpu) = 1) {
		int ret;
		if ((ret = salinfo_log_clear(data, cpu)))
			count = ret;
	}

	return count;
}

static struct file_operations salinfo_data_fops = {
	.open    = salinfo_log_open,
	.release = salinfo_log_release,
	.read    = salinfo_log_read,
	.write   = salinfo_log_write,
};

static int __init
salinfo_init(void)
{
	struct proc_dir_entry *salinfo_dir; /* /proc/sal dir entry */
	struct proc_dir_entry **sdir = salinfo_proc_entries; /* keeps track of every entry */
	struct proc_dir_entry *dir, *entry;
	struct salinfo_data *data;
	int i, j, online;

	salinfo_dir = proc_mkdir("sal", NULL);
	if (!salinfo_dir)
		return 0;

	for (i=0; i < NR_SALINFO_ENTRIES; i++) {
		/* pass the feature bit in question as misc data */
		*sdir++ = create_proc_read_entry (salinfo_entries[i].name, 0, salinfo_dir,
						  salinfo_read, (void *)salinfo_entries[i].feature);
	}

	for (i = 0; i < ARRAY_SIZE(salinfo_log_name); i++) {
		data = salinfo_data + i;
		data->type = i;
		sema_init(&data->sem, 0);
		dir = proc_mkdir(salinfo_log_name[i], salinfo_dir);
		if (!dir)
			continue;

		entry = create_proc_entry("event", S_IRUSR, dir);
		if (!entry)
			continue;
		entry->data = data;
		entry->proc_fops = &salinfo_event_fops;
		*sdir++ = entry;

		entry = create_proc_entry("data", S_IRUSR | S_IWUSR, dir);
		if (!entry)
			continue;
		entry->data = data;
		entry->proc_fops = &salinfo_data_fops;
		*sdir++ = entry;

		/* we missed any events before now */
		online = 0;
		for (j = 0; j < NR_CPUS; j++)
			if (cpu_online(j)) {
				set_bit(j, &data->cpu_event);
				++online;
			}
		sema_init(&data->sem, online);

		*sdir++ = dir;
	}

	*sdir++ = salinfo_dir;

	return 0;
}

/* FIXME: Although this source has a module_exit function, the code cannot be
 * built as a module.  mca.c has an unconditional call to salinfo_log_wakeup()
 * which will be unresolved if salinfo.c is a module.
 */
static void __exit
salinfo_exit(void)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(salinfo_proc_entries); i++) {
		if (salinfo_proc_entries[i])
			remove_proc_entry (salinfo_proc_entries[i]->name, NULL);
	}

	for (i = 0; i < ARRAY_SIZE(salinfo_log_name); i++) {
		vfree(salinfo_data[i].log_buffer);
	}
}

/*
 * 'data' contains an integer that corresponds to the feature we're
 * testing
 */
static int
salinfo_read(char *page, char **start, off_t off, int count, int *eof, void *data)
{
	int len = 0;

	MOD_INC_USE_COUNT;

	len = sprintf(page, (sal_platform_features & (unsigned long)data) ? "1\n" : "0\n");

	if (len <= off+count) *eof = 1;

	*start = page + off;
	len   -= off;

	if (len>count) len = count;
	if (len<0) len = 0;

	MOD_DEC_USE_COUNT;

	return len;
}

module_init(salinfo_init);
module_exit(salinfo_exit);

