From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 18 Nov 2003 10:14:23 +0000
Subject: [RFC] How drivers notice a MCA on I/O read? [3/3]
Message-Id: <marc-linux-ia64-106915060530349@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106915044130197@msgid-missing>
In-Reply-To: <marc-linux-ia64-106915044130197@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is a sample of readb_check on kernel.

I certainly understand that some of this code should be written in assemblers,
but I‘m not sure in my skill to handle IA64 codes. I would appreciate any
comments and feedbacks.

-----

H.Seto <seto.hidetoshi@jp.fujitsu.com>



/******************************************************************************/
/************************************* MCA ************************************/
/******************************************************************************/
...
typedef struct {
 void *start;
 void *end;
} address_range;

int readb_check(unsigned char*, void*);
int readw_check(unsigned short*, void*);
int readl_check(unsigned int*, void*);
static address_range check_range[] = {
 {(void*)readb_check, (void*)readw_check},
 …
};

void MCA_Handler(struct pt_regs *ptregs)
{
/* 'ip' is index of register instruction pointer */
/* 'A' is index of register A */
…
 /* statements for read_check */
 for (int i = 0; i < sizeof(check_range)/sizeof(address_range); i ++) {
  if (check_range[i].start <= ptregs['ip']
   && ptregs['ip'] <= check_range[i].end) {
   if (ptregs['A'] = current->pid) {/* register A*/
    ptregs['A'] = 0;
    break;
   }
  }
 }
…
}
…


/******************************************************************************/
/********************************** read_check ********************************/
/******************************************************************************/
__attribute__((noinline)) int readb_check(unsigned char *data, void *adrs)
{
 int volatile B = current->pid;
 register int volatile A asm("A") /* register A */
 unsigned char  ret;

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

__attribute__((noinline)) int readw_check(unsigned short *data, void *adrs)
{
…


/******************************************************************************/
/************************************ DRIVER **********************************/
/******************************************************************************/
…
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


