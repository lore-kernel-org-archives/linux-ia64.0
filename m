From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 31 Jul 2001 01:28:38 +0000
Subject: Re: [Linux-ia64] patch ia32 mode [Threads don't wake up in ia32 mode]
Message-Id: <marc-linux-ia64-105590693005963@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005927@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005927@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch looks correct to me, so I applied.  Don, speak up if you
object...

	--david

>>>>> On Thu, 26 Jul 2001 19:34:47 +0200, "Jose Luu" <jluu@mainsoft.com> said:

  Jose> This is the solution to the problem I described in june,

  Jose> see test case there:
  Jose> https://external-lists.valinux.com/archives//linux-ia64/2001-June/001792.htm
  Jose> l

  Jose> There was an oversight on the size of the long, which caused
  Jose> an improper restoration of the real time signals blocking mask
  Jose> of the 32 bit frame, 2 of these signals are used by the
  Jose> pthreads library for wakeup or cancellation.

  Jose> This patch can be applied to all 2.4.x series kernels
  Jose> including 2.4.7, since the file has not changed.

  Jose> Jose


  Jose> --- 2.4.5/arch/ia64/ia32/ia32_signal.c Tue Oct 10 02:54:53
  Jose> 2000 +++ new-2.4.5/arch/ia64/ia32/ia32_signal.c Thu Jul 26
  Jose> 12:49:42 2001 @@ -279,7 +279,7 @@ err |  Jose> setup_sigcontext_ia32(&frame->sc, &frame->fpstate, regs,
  set-> sig[0]);

  Jose>         if (_IA32_NSIG_WORDS > 1) { - err |  Jose> __copy_to_user(frame->extramask, &set->sig[1], + err |  Jose> __copy_to_user(frame->extramask,(((char *) &set->sig) + 4) ,
  Jose> sizeof(frame->extramask)); }



  Jose> _______________________________________________ Linux-IA64
  Jose> mailing list Linux-IA64@linuxia64.org
  Jose> http://lists.linuxia64.org/lists/listinfo/linux-ia64

