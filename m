From: Jack F Vogel <jfv@bluesong.net>
Date: Tue, 25 Jan 2005 05:52:18 +0000
Subject: Re: Announce: kdb v4.4 is available for kernel 2.6.10
Message-Id: <20050125055218.GA15014@trane.bluesong.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <51a933b50501242025645ef27a@mail.gmail.com> <15313.1106628266@kao2.melbourne.sgi.com>
In-Reply-To: <15313.1106628266@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@sgi.com>
Cc: Saravanan s <saravanan.mainker@gmail.com>, kdb@oss.sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, Jan 25, 2005 at 03:44:26PM +1100, Keith Owens wrote:
> On Tue, 25 Jan 2005 09:55:55 +0530, 
> Saravanan s <saravanan.mainker@gmail.com> wrote:
> >Hi Keith,
> >
> >> I have no hardware to test on, so I have
> >> to rely on HP to keep the USB patches in KDB up to date. 
> >
> >Does that mean that there is USB support for KDBv4.4 for kernel 2.6 
> >for i386 machines? Or the patch for i386 also comes from the HP guys.
> 
> All the USB console patches for kdb came from HP, both i386 and ia64.
> Neither work in 2.6 kernels at the moment.
  
I have been looking at the USB code and talked with gregkh about 
it a bit, it looks to me that in order for this to work its going
to take a self-contained polling driver. I've been busy so I havent
looked too far yet for any pre-existent code that could be utilized.
It may need to be written from scratch, which I also might attempt
once I get my queue a bit reduced.

But as is the code thats there isnt even close to working, its just
a bit of infrastructure.

Cheers,

Jack

