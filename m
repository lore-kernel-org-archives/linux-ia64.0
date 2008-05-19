From: Matthew Chapman <matthewc@cse.unsw.edu.au>
Date: Mon, 19 May 2008 12:12:27 +0000
Subject: Re: ld2.acq - sign extension?
Message-Id: <20080519121227.GA32627@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0wslqiqyp.fsf@jaguar.mkp.net>
In-Reply-To: <yq0wslqiqyp.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes,

You mentioned that you're running on KVM... while I don't know much
about how KVM works, is that load instruction being intercepted and
emulated by any chance?  (Considering that it looks like something that
would be accessing hardware registers on a real machine.)  A bug in that
emulation could explain why it's behaving strangely...

Matt


On Mon, May 19, 2008 at 05:27:26AM -0400, Jes Sorensen wrote:
> Hi,
> 
> Trying to figure out if it's GCC being broken or what else could be
> causing this problem.
> 
> I am chasing an issue where the console hangs when I boot my self
> compiled kernels under KVM. I have tracked down the problem to a
> single instruction change in the vgacon driver, however if I
> understand the rules correctly this specific change should not cause
> any difference in code execution whatsoever?
> 
> Basically if I apply the below diff my code no longer works. However I
> am under the impression that ld2.acq does sign extension? If thats the
> case, does anybody have an explanation for why my bode breaks if I
> don't perform the zxt2 instruction on the previously loaded register
> before the comparison? Note the mov r19=r17 at the end, which should
> mean there is no reason why this change should affect code flow
> further down the lin...
> 
> Any input would be greatly appreciated, I have been trying to track
> this down for a couple of weeks and I still don't get why this is
> going wrong.
> 
> Thanks,
> Jes
> 
> 
> --- /tmp/vgacon-good.S  2008-05-16 06:09:08.000000000 -0500
> +++ /tmp/vgacon-test2.S 2008-05-19 03:54:45.000000000 -0500
> @@ -113,22 +113,22 @@
>         ld2.acq r21 = [r18], 2
>         ;;
>         ld2.acq r16 = [r18]
>         nop 0
>         .mmi
>         st2.rel [r8] = r20
>         st2.rel [r18] = r22
>         zxt2 r15 = r21
>         .mii
> -       ld2.acq r19 = [r8]
> +       ld2.acq r17 = [r8]
>         nop 0
>         ;;
> -       zxt2 r17 = r19
> +       zxt2 r19 = r19
>         .mib
>         nop 0
>         zxt2 r16 = r16
>         nop 0
>         ;;
>         .mib
>         cmp4.ne p8, p9 = r11, r17
>         mov r19 = r17
>         (p8) br.cond.dpnt .L8
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
