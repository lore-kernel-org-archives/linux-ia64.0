From: "ARADHYA, CHINMAYA TM (STSD)" <chinmaya@hp.com>
Date: Tue, 04 May 2004 15:45:15 +0000
Subject: RE: IPC_STAT on ia64
Message-Id: <8BF7471D09AA9B4190A9C96778BC2A170108B9A0@qcaexc02.asiapacific.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <8BF7471D09AA9B4190A9C96778BC2A170108B854@qcaexc02.asiapacific.cpqcorp.net>
In-Reply-To: <8BF7471D09AA9B4190A9C96778BC2A170108B854@qcaexc02.asiapacific.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I ran the test on Kernel ver 2.4.21, The behaviour was sane.

There were indeed some IPC_STAT related issues fixed in this
version. 

>>>>>>>
2.4.21 Fixes

* IA32 emulation:
    .
    .
    .
    - fix shmctl(IPC_STAT) (Arun Sharma).
>>>>>>>>

thx
Chinmaya


>>-----Original Message-----
>>From: Helgaas, Bjorn 
>>Sent: Tuesday, May 04, 2004 8:53 PM
>>To: ARADHYA, CHINMAYA TM (STSD)
>>Cc: Linux-Ia64 (E-mail)
>>Subject: Re: IPC_STAT on ia64
>>
>>
>>On Tuesday 04 May 2004 3:22 am, ARADHYA, CHINMAYA TM (STSD) wrote:
>>> I noticed that when a 32bit application running on a ia64 system 
>>> makes a shmctl call  with IPC_STAT flag junk data will be filled 
>>> in the shmid_ds structure.
>>> This is on the kernel version - 2.4.18-e.12smp
>>
>>2.4.18 was released almost two years ago.  There were some
>>shmctl(IPC_STAT) changes in 2.4.21.  Can you run your test
>>on a current kernel (linux-2.4.25-ia64-040218 (yes, I need to
>>get the 2.4.26 patch out)) and see whether it's still broken?
>>
>>Bjorn
>>
