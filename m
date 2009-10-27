From: Takao Indoh <indou.takao@jp.fujitsu.com>
Date: Tue, 27 Oct 2009 22:21:11 +0000
Subject: Re: why ms->pmsa_xip is used?
Message-Id: <6CA5753CA29E6indou.takao@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <F6CA51BB11EE80indou.takao@jp.fujitsu.com>
In-Reply-To: <F6CA51BB11EE80indou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Tue, 27 Oct 2009 10:36:53 +1100, Keith Owens wrote:

>On Mon, 26 Oct 2009 18:15:22 -0400,=20
>Takao Indoh <indou.takao@jp.fujitsu.com> wrote:
>>As Intel manual says, it seems that pmsa_iip has a value of ip register
>>where INIT interrupted when psr.ic is 0. Ok, I'll make a patch so that
>>pmsa_iip is used irrespective of a value of psr.ic.
>>
>>Please let me know if I need to confirm something else before I make a
>>patch.
>
>That looks good.  The only problem I can think of is an MCA/INIT
>arriving while code like SAVE_MIN or SAVE_REST is executing.  Back
>tracing at that point using pmsa_iip is going to be a problem, you have
>no idea what state the registers or stack are in.

I inserted another debug code into IA64_NATIVE_DO_SAVE_MIN to send
INIT during SAVE_MIN.

diff -Nurp a/arch/ia64/kernel/minstate.h b/arch/ia64/kernel/minstate.h
--- a/arch/ia64/kernel/minstate.h   2009-10-22 12:28:07.000000000 -0400
+++ b/arch/ia64/kernel/minstate.h   2009-10-27 12:42:02.000000000 -0400
@@ -55,6 +55,14 @@
    mov r21=3Dar.fpsr;        /* M */                         \
    __COVER;                /* B;; (or nothing) */              \
    ;;                                          \
+   movl r24=DEbug_flag;    \
+   ;;  \
+   ld8 r23=3D[r24];  \
+   ;;  \
+   cmp.eq p2,p3=3D0,r23; \
+(p2) br.sptk 2f;   \
+1:   br.sptk 1b;   \
+2: \
    adds r16=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r16;                     \
    ;;                                          \
    ld1 r17=3D[r16];              /* load current->thread.on_ustack flag */=
   \

As a result, backtrace in the case using xip works, and backtrace in the
case using iip does NOT work, as you said. Hm, it seems that I have to
reconsider how to fix.

Thanks,
Takao Indoh
