From: Bill Nottingham <notting@redhat.com>
Date: Wed, 03 Oct 2001 21:15:53 +0000
Subject: [Linux-ia64] Re: X4.1.0 reboots and log
MIME-Version: 1
Content-Type: multipart/mixed; boundary="n8g4imXOkfNTN/H1"
Message-Id: <marc-linux-ia64-105590698805297@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

David Mosberger (davidm@hpl.hp.com) said: 
>   Randolph> Does this help anyone debug the problem? I was told that
>   Randolph> this:
> 
> It's definitely a useful observation; thanks for pointing it out.

Here's my error log. Of note is that running the X server under gdb
appears to not cause the problem. (mmm, timing...)

Bill

--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=messages

kernel:  Processor Error Map: 0x1000000
kernel:  Processor State Param: 0x20000000fff21320
kernel:  Processor LID: 0x0
kernel: + BUS Check Info [0]
kernel: + Status Info: 0 ,Severity: 0 ,Transaction Type: 1 ,Transaction Size: 7 ,Error: External
kernel:  CPUID Regs: 0x49656e69756e6547 0x6c65746e 0x0 0x7000604
kernel: SAL SECTION HEADER:  Record buffer = e000000004a05218,  header size = 24
kernel: e000000004a05218 f6 fa 29 e4 b7 3c d4 11 bc a7 00 80 c7 3c 88 81 
kernel: e000000004a05228 02 00 00 00 70 00 00 00 
kernel: Length of section & header = 112
kernel: GUID = { e429faf6, 3cb7, 11d4, { 0xbc, 0xa7, 0x0, 0x80, 0xc7, 0x3c, 0x88, 0x81, } } 
kernel:  End of SAL SECTION HEADER
kernel: Start of Platform Err Data Section:  Data buffer = e000000004a05230, Data size = 88
kernel: e000000004a05230 1b 00 00 00 00 00 00 00 00 10 00 00 00 00 00 00 
kernel: e000000004a05240 86 80 e0 84 00 00 06 00 00 04 00 00 00 00 00 00 
kernel: e000000004a05250 00 00 00 00 02 00 00 00 50 00 00 00 00 00 00 00 
kernel: e000000004a05260 60 17 1f 00 00 00 00 00 54 00 00 00 00 00 00 00 
kernel: e000000004a05270 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
kernel: e000000004a05280 00 00 00 00 00 00 00 00 
kernel: End of Platform Err Data Section
kernel: +Platform PCI Component Error Info Section
kernel: + PCI Component Error Detail:  Error Status: 0x1000
kernel:  Component Info: Vendor Id = 0x8086, Device Id = 0x84e0, Class Code = 0x0, Seg/Bus/Dev/Func = 4/0/0/6
kernel:  I/O Mapped Registers
kernel:  Address ^IValue
kernel:  0x50 0x1f1760
kernel:  0x54 0x3
kernel: SAL SECTION HEADER:  Record buffer = e000000004a05288,  header size = 24
kernel: e000000004a05288 f6 fa 29 e4 b7 3c d4 11 bc a7 00 80 c7 3c 88 81 
kernel: e000000004a05298 02 00 00 00 70 00 00 00 
kernel: Length of section & header = 112
kernel: GUID = { e429faf6, 3cb7, 11d4, { 0xbc, 0xa7, 0x0, 0x80, 0xc7, 0x3c, 0x88, 0x81, } } 
kernel:  End of SAL SECTION HEADER
kernel: Start of Platform Err Data Section:  Data buffer = e000000004a052a0, Data size = 88
kernel: e000000004a052a0 1b 00 00 00 00 00 00 00 00 10 00 00 00 00 00 00 
kernel: e000000004a052b0 86 80 e0 84 00 00 06 01 00 04 00 00 00 00 00 00 
kernel: e000000004a052c0 00 00 00 00 02 00 00 00 40 00 00 00 00 00 00 00 
kernel: e000000004a052d0 10 00 00 00 00 00 00 00 44 00 00 00 00 00 00 00 
kernel: e000000004a052e0 10 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00 
kernel: e000000004a052f0 00 00 00 00 00 00 00 00 
kernel: End of Platform Err Data Section
kernel: +Platform PCI Component Error Info Section
kernel: + PCI Component Error Detail:  Error Status: 0x1000
kernel:  Component Info: Vendor Id = 0x8086, Device Id = 0x84e0, Class Code = 0x0, Seg/Bus/Dev/Func = 4/0/1/6
kernel:  I/O Mapped Registers
kernel:  Address ^IValue
kernel:  0x40 0x10
kernel:  0x44 0x800010
kernel: SAL SECTION HEADER:  Record buffer = e000000004a052f8,  header size = 24
kernel: e000000004a052f8 f6 fa 29 e4 b7 3c d4 11 bc a7 00 80 c7 3c 88 81 
kernel: e000000004a05308 02 00 00 00 70 00 00 00 
kernel: Length of section & header = 112
kernel: GUID = { e429faf6, 3cb7, 11d4, { 0xbc, 0xa7, 0x0, 0x80, 0xc7, 0x3c, 0x88, 0x81, } } 
kernel:  End of SAL SECTION HEADER
kernel: Start of Platform Err Data Section:  Data buffer = e000000004a05310, Data size = 88
kernel: e000000004a05310 1b 00 00 00 00 00 00 00 00 16 04 00 00 00 00 00 
kernel: e000000004a05320 86 80 e1 84 00 00 06 00 04 04 00 00 00 00 00 00 
kernel: e000000004a05330 00 00 00 00 02 00 00 00 80 00 00 00 00 00 00 00 
kernel: e000000004a05340 40 00 00 00 00 00 00 00 84 00 00 00 00 00 00 00 
kernel: e000000004a05350 40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
kernel: e000000004a05360 00 00 00 00 00 00 00 00 
kernel: End of Platform Err Data Section
kernel: +Platform PCI Component Error Info Section
kernel: + PCI Component Error Detail:  Error Status: 0x41600
kernel:  Component Info: Vendor Id = 0x8086, Device Id = 0x84e1, Class Code = 0x0, Seg/Bus/Dev/Func = 4/4/0/6
kernel:  I/O Mapped Registers
kernel:  Address ^IValue
kernel:  0x80 0x40
kernel:  0x84 0x40
kernel: SAL SECTION HEADER:  Record buffer = e000000004a05368,  header size = 24
kernel: e000000004a05368 f6 fa 29 e4 b7 3c d4 11 bc a7 00 80 c7 3c 88 81 
kernel: e000000004a05378 02 00 00 00 60 00 00 00 
kernel: Length of section & header = 96
kernel: GUID = { e429faf6, 3cb7, 11d4, { 0xbc, 0xa7, 0x0, 0x80, 0xc7, 0x3c, 0x88, 0x81, } } 
kernel:  End of SAL SECTION HEADER
kernel: Start of Platform Err Data Section:  Data buffer = e000000004a05380, Data size = 72
kernel: e000000004a05380 1b 00 00 00 00 00 00 00 00 10 00 00 00 00 00 00 
kernel: e000000004a05390 86 80 e0 84 00 00 06 00 16 04 00 00 00 00 00 00 
kernel: e000000004a053a0 00 00 00 00 01 00 00 00 b0 00 00 00 00 00 00 00 
kernel: e000000004a053b0 08 00 08 00 00 00 00 00 00 00 00 00 00 00 00 00 
kernel: e000000004a053c0 00 00 00 00 00 00 00 00 
kernel: End of Platform Err Data Section
kernel: +Platform PCI Component Error Info Section
kernel: + PCI Component Error Detail:  Error Status: 0x1000
kernel:  Component Info: Vendor Id = 0x8086, Device Id = 0x84e0, Class Code = 0x0, Seg/Bus/Dev/Func = 4/22/0/6
kernel:  I/O Mapped Registers
kernel:  Address ^IValue
kernel:  0xb0 0x80008
kernel: SAL SECTION HEADER:  Record buffer = e000000004a053c8,  header size = 24
kernel: e000000004a053c8 f6 fa 29 e4 b7 3c d4 11 bc a7 00 80 c7 3c 88 81 
kernel: e000000004a053d8 02 00 00 00 90 00 00 00 
kernel: Length of section & header = 144
kernel: GUID = { e429faf6, 3cb7, 11d4, { 0xbc, 0xa7, 0x0, 0x80, 0xc7, 0x3c, 0x88, 0x81, } } 
kernel:  End of SAL SECTION HEADER
kernel: Start of Platform Err Data Section:  Data buffer = e000000004a053e0, Data size = 120
kernel: e000000004a053e0 1b 00 00 00 00 00 00 00 00 10 00 00 00 00 00 00 
kernel: e000000004a053f0 86 80 e2 84 00 80 06 02 14 04 00 00 00 00 00 00 
kernel: e000000004a05400 00 00 00 00 04 00 00 00 80 00 00 00 00 00 00 00 
kernel: e000000004a05410 04 00 00 00 00 00 00 00 84 00 00 00 00 00 00 00 
kernel: e000000004a05420 40 00 00 00 00 00 00 00 88 00 00 00 00 00 00 00 
kernel: e000000004a05430 04 00 00 00 00 00 00 00 8c 00 00 00 00 00 00 00 
kernel: e000000004a05440 40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
kernel: e000000004a05450 00 00 00 00 00 00 00 00 
kernel: End of Platform Err Data Section
kernel: +Platform PCI Component Error Info Section
kernel: + PCI Component Error Detail:  Error Status: 0x1000
kernel:  Component Info: Vendor Id = 0x8086, Device Id = 0x84e2, Class Code = 0x8000, Seg/Bus/Dev/Func = 4/20/2/6
kernel:  I/O Mapped Registers
kernel:  Address ^IValue
kernel:  0x80 0x4
kernel:  0x84 0x40
kernel:  0x88 0x4
kernel:  0x8c 0x40
kernel: ia64_mca_log_print : found 6 sections in SAL error record. len = 6024
kernel: +END HARDWARE ERROR STATE AT MCA

--n8g4imXOkfNTN/H1--

