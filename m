From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 18 Nov 2003 10:12:35 +0000
Subject: [RFC] How drivers notice a MCA on I/O read? [2/3]
Message-Id: <marc-linux-ia64-106915049930244@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106915044130197@msgid-missing>
In-Reply-To: <marc-linux-ia64-106915044130197@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is a sample of readb_check on driver (with Notifier).

I certainly understand that some of this code should be written in assemblers,
but I‘m not sure in my skill to handle IA64 codes. I would appreciate any
comments and feedbacks.

-----

H.Seto <seto.hidetoshi@jp.fujitsu.com>


/******************************************************************************/
/************************************* MCA ************************************/
/******************************************************************************/
struct notifier_block *driver_notifier_list = { 0, 0, 0};
EXPORT_SYMBOL(driver_notifer_list)

void MCA_Handler(struct pt_regs *ptregs)
{
/* 'ip' is index of register instruction pointer */
/* 'A' is index of register A */
 int check = 0;
…
 /* statements for read&mf */
 if (ptregs['A'] = current->pid) {
  int ret = notifier_call_chain(&driver_notifier_chain,
       0, ptregs['ip']);
  if ((ret&~NOTIFY_STOP_MASK) = NOTIFY_OK) {
   ptregs['A'] = 0;
   check = 1;
  }
 }
 if (!check) reboot(); /* system down */
…
}
…

/******************************************************************************/
/************************************ DRIVER **********************************/
/******************************************************************************/
…
static struct notifer_block driver_notifer = {
 .notifer_call = driver_notifer_hook,
};
typedef struct {
 void *start;
 void *end;
} address_range;

static __attribute__((noinline))
int readb_check(unsigned char *data, void *adrs)
{
 int volatile B = current->pid;
 register int A asm("A") /* register A */
 unsigned char ret;

 A = B;
 ret = read(adrs);
 asm("mf.a"::);
 if (A != B) {
  return 0; /* false*/
 } else {
  *data = ret;
  return 1; /* true */
 }
}

static __attribute__((noinline))
int readw_check(unsigned short *data, void *adrs)
…

/* fixme: specify address range from 'read(adrs)' to 'asm("mf.a"::)' */
static address_range check_range[] = {
 {readb_check, readw_check},
 …
};

static int driver_notifier_hook(struct notifier_block *this,
    unsigned long event, void *data)
{
 void *adr = data;
 int res = NOTIFY_DONE;
 int i;

 for (i = 0; i < sizeof(check_range)/sizeof(address_range);  i++ ) {
  if (check_range[i].start < adr && adr < check_range[i].end) {
   res = NOTIFY_STOP_MASK|NOTIFY_OK;
   break;
  }
 }
 return res;
}

static int __init driver_init(void)
{
…
 notifier_chain_register(&driver_notifier_list, &driver_notifier);
…
}

static void __exit driver_exit(void)
{
 notifier_chain_unregister(&driver_notifer_list, &driver_notifier);
…
}

module_init(driver_init);
module_exit(driver_exit);

DRIVER_MAIN()
{
 unsigned char data;
 int retry_count, i;
…
 retry_count = N1;
 for ( i = 0; i < retry_count; i ++ ) {
  if (readb_check(&data, address1)) break;
 }
 if ( i = retry_count) {
  /* error */
 }
…
 retry_count = N2;
 for ( i = 0; i < retry_count; i ++ ) {
  if (readb_check(&data, address2)) break;
 }
 if ( i = retry_count) {
  /* error */
 }
…
}


