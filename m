From: Chris McDermott <lcm@us.ibm.com>
Date: Wed, 09 Jan 2002 01:59:31 +0000
Subject: Re: [Linux-ia64] Re: IA64 Kernel Question (David Mosberger)
Message-Id: <marc-linux-ia64-105590698805780@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805774@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805774@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jan 08, 2002 at 07:50 -0600, Robert K Gjertsen wrote: 
> 
> On Mon, Jan 07, 2002 at 13:48 -0800, David Mosberger wrote:
> > >>>>> On Mon, 07 Jan 2002 10:20:15 -0800, Michael Madore
> <mmadore@turbolinux.com> said:
> >
> >   Michael> Hi, I am seeing frequent lockups on my Lion box running
> >   Michael> 2.4.17.  I have firmware 76 installed.  Does anyone have
> >   Michael> this kernel running reliably on a lion box?  If so, what
> >   Michael> firmware version are you using.  I was running 2.4.9
> >   Michael> previously, and that seemed to be pretty stable.
> >
> > I suspect you need fw 99 or newer.  Trouble is: I don't think Intel
> > has released those newer versions on Quad yet.
> >
> >          --david
> >
> And from what I understand, Intel does not plan to release on QuAD,
> any fw greater than 83B. FW revisions > 83B are not supported on
> Intel Lions, only OEM platforms. If you install an unsupported FW
> revision on a Lion, and you experience H/W problems, Intel will not
> support you. Speaking from personal experience here.
> 
> Chris
> 
> I tried out level 99 on a Lion and it seemed to work OK other than the fact
> that
> the fan failure light would come on (no fans were out) and the fans were
> twice as noisy as usual. I backed down to 83B after talking with Intel
> support.
> I'm using RH beta 3 (2.4.9.7 kernel) and that is OK. I had problems
> upgrading
> from RH beta2 where I was getting random kernel panics until I scrubbed the
> disks
> and did a fresh install, although that doesn't help with TL.
> 
> --Rob

Rob,

My experience was that using any kernel revision greater than 2.4.13 
(I think, I would have to go back and look at my notes) resulted in
the kind of instability issues Michael reported (random, frequent
lockups). This instability occurred with BIOS 76, 79, 81, 83. When
I upgraded to BIOS 99, the system was much more stable. I haven't
booted a 2.4.17 kernel on a Lion yet, so I can't be 100% sure it's
the same issue. However, this is definitely the symptoms I saw
with 2.4.16.  As luck would have it, one of the systems I upgraded
to BIOS 99 had a H/W failure. Intel support told me there was nothing
they could do for me, since I was running an unsupported BIOS. So,
I down-reved the BIOS to 83B, got my H/W fixed, then reflashed
99.  

Chris


