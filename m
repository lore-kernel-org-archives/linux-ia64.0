From: Keith Owens <kaos@sgi.com>
Date: Fri, 04 Feb 2005 03:00:15 +0000
Subject: Re: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <24266.1107486015@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 3 Feb 2005 20:09:57 -0600, 
Jack Steiner <steiner@sgi.com> wrote:
>On Thu, Feb 03, 2005 at 05:48:26PM -0600, Russ Anderson wrote:
>> According to the SAL Spec, MCAs are supposed to be handled
>> one at a time.  
>
>It has been a long time since I looked, but I thought the
>spec allowed either implemention, ie. serialize OR all-at-once.
>
>Maybe I'm remembering the error handling guide but I know
>I have seen this somewhere.....

It is ambiguous.  Extracts from SAL spec.

4.1.1 says only one processor gets OS_MCA.

  When multiple processors experience machine checks simultaneously,
  SAL selects a "monarch" machine check processor to accumulate all the
  error records at the platform level and continue with the machine
  check processing. "Monarch" status is relevant only for the current
  MCA error event.

4.7.2 (5) also says only one processor.

  5. SAL selects a monarch for handling the error. All slaves
     processors in SAL_MC_RENDEZ check in their status with the SAL on
     the monarch.

But the last sentence of 4.7.2 (8) refers to multiple processors in OS
MCA.

  8. SAL finishes the MCA handling on all the processors that are in
     MCA and waits for all the processors in MCA to synchronize before
     branching to OS MCA for further processing.  Note that the
     hand-off to OS MCA from SAL MCA occurs simultaneously on all
     processors executing in SAL MCA handler.

4.7.2 (9) lets the OS choose the monarch, which implies that more than
one cpu can be in OS MCA handler.

  9. OS_MCA may choose a monarch processor to continue with error
     handling. After OS_MCA completes the error handling, the monarch
     processor wakes up all the slaves through a wake-up message as
     shown by (9) in Figure 4-4

The end of 4.7.3 also implies that OS MCA handler can be running on
multiple cpus. Note 'on all the processors'.

  When multiple processors experience machine checks simultaneously,
  SAL selects a monarch machine check processor to accumulate all the
  error records at the platform level. Once this is done, the OS_MCA
  procedure will take control of further error handling on all the
  processors that experienced the machine checks. The OS_MCA layer may
  need to implement a similar monarch processor selection for the error
  recovery phase. The operating system will be aware of which
  processors invoked the SAL_MC_RENDEZ procedure in response to the
  MC_rendezvous interrupt or the INIT signal and shall wake up those
  processors.

