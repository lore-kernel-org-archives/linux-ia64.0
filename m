From: Keith Owens <kaos@sgi.com>
Date: Wed, 05 Mar 2003 02:11:19 +0000
Subject: [Linux-ia64] Re: [patch] 2.4.20-021210 misaligned sal error record
Message-Id: <marc-linux-ia64-105590709805971@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 4 Mar 2003 16:01:20 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>+/* Given a sal_log_processor_info_t pointer, return a pointer to the processor_static_info: */
>+#define SAL_LPI_PSI_INFO(l)								\
>+({	sal_log_processor_info_t *_l = (l);						\
>+	((sal_processor_static_info_t *)						\
>+	 ((char *) _l + ((_l->valid.num_cache_check + _l->valid.num_tlb_check		\
                   ^^  must be &_l->info
	 ((char *) &_l->info + ((_l->valid.num_cache_check + _l->valid.num_tlb_check	\

With that change, kdb v4.0 gets accurate backtraces from INIT monarch.
BTW, your patch does not fit 2.4.20-ia64-021210, looks like it is
against 2.5.

# modprobe kdbm_kaos
forcing init
Entered OS INIT handler
+BEGIN HARDWARE ERROR STATE AT INIT
+ Err Record ID: 1    SAL Rev:	0.02
+ Time: 03/05/2003/ 02:01:30	Severity 0
+ Processor Device Error Info Section
+ Processor State Param: 0xffe301a0
+ Processor LID: 0x0
+ CPUID Regs: 0x49656e69756e6547 0x6c65746e 0x0 0x1f000604
....
+END HARDWARE ERROR STATE AT INIT
  nat=0x0000000000000000    r1=0xe00210000092c000    r2=0xe000003014723e48
   r3=0xe000003014723e38    r4=0x0000000000000000    r5=0x80000000ffe71ce0
   r6=0x80000087fed30000    r7=0x0000000000000040    r8=0x0000000000000000
   r9=0xffffffffffffffff   r10=0x0000000000000000   r11=0x80000000ff670159
  r12=0xe000003014723e50   r13=0xe00000301471c000   r14=0x0000000000000000
  r15=0x0000000000000000 b0r16=0xe00000301471d318 b0r17=0x0000000000000308
b0r18=0x0000000000000000 b0r19=0x0000000000000000 b0r20=0xe00210000092c000
b0r21=0xe00200000015af60 b0r22=0x0000000000000000 b0r23=0x000000000001003e
b0r24=0x8000000000000012 b0r25=0x0000000000000000 b0r26=0x000000000000068d
b0r27=0x0000000000000003 b0r28=0xe0020000000168f0 b0r29=0x0000121008026018
b0r30=0x800000000000068d b0r31=0x80000000ff654989   r16=0xc0000087fed00000
  r17=0xe00000301471c028   r18=0xa000000000008420   r19=0x0009804c8a70033f
  r20=0x000000301471c000   r21=0xe0020000000cf8d0   r22=0x80000000ffe793b0
  r23=0x0000000000000000   r24=0x0000000000000000   r25=0x0000000000000000
  r26=0x0000000000000000   r27=0xe00000301471d368   r28=0x80000000ff654a89
  r29=0x0000000000000000   r30=0x0000000000000000   r31=0xe002100000827968
preds=0x80000000ff654989   br0=0xe002000000016990   rsc=0x0000000000000003
  iip=0xe0020000000168f0  ipsr=0x0000121008026018   ifs=0x800000000000068d
  xip=0xe0020000000168f0  xpsr=0x0000121008026018   xfs=0x800000000000068d

Entering kdb (current=0xe00000301471c000, pid 0) on processor 0
[0]kdb> bt
0xe00000301471c000	  0	   0  1	   0   R  0xe00000301471c7d0 *swapper
0xe0020000000168f0 cpu_idle+0xb0
	args (0xe0021000008c6a88, 0xa000000000008418, 0x1e0008, 0xa000000000008410, 0xfffffffffffffffd)
	kernel .text 0xe002000000000000 0xe002000000016840 0xe002000000016ae0
0xe002000000009170 rest_init+0x90
	args (0xe00200000064d1a0, 0x186)
	kernel .text 0xe002000000000000 0xe0020000000090e0 0xe0020000000091a0
0xe00200000064d1a0 start_kernel+0x5c0
	args (0xe0021000008f0f90, 0xe0020000000084d0, 0x794)
	kernel .text.init 0xe00200000064c000 0xe00200000064cbe0 0xe00200000064d1c0
0xe0020000000084d0 start_ap+0x2b0
	args (0x2bc3bf5b000, 0x3004a3e500, 0x3, 0x3, 0x2bc3bd8c408)
	kernel .text 0xe002000000000000 0xe002000000008220 0xe0020000000084f0

kdb v4.0 bt was constructed from the SAL_INFO_TYPE_INIT min state data.

        plog_ptr = (ia64_err_rec_t *)IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_INIT);
        if (plog_ptr)
                s = SAL_LPI_PSI_INFO(&plog_ptr->proc_err);


