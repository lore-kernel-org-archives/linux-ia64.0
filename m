From: Erich Focht <efocht@ess.nec.de>
Date: Sat, 20 Jul 2002 12:32:11 +0000
Subject: [Linux-ia64] Re: [PATCH]: scheduler complex macros fixes
Message-Id: <marc-linux-ia64-105590701905796@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905791@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Ingo,

On Saturday 20 July 2002 19:43, Ingo Molnar wrote:
> On Fri, 19 Jul 2002, Linus Torvalds wrote:
> > So I'd rather have the non-batch stuff done first and independently.
>
> sure - all the non-batch bits are attached, against 2.5.26-vanilla. It
> compiles & boots just fine on UP & SMP as well.
>
>         Ingo

thanks for the complete update without the SCHED_BATCH! I was too lazy
to strip out all your changes and I'm sure I would have made mistakes...

Best regards,
Erich


