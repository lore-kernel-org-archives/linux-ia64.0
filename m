From: Saravanan s <saravanan.mainker@gmail.com>
Date: Tue, 25 Jan 2005 04:37:55 +0000
Subject: Re: Announce: kdb v4.4 is available for kernel 2.6.10
Message-Id: <51a933b50501242025645ef27a@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <50C05B7AA7D6924FB5E384EF14BC647BC451EE@inba1mx2.corp.emc.com>
	 <14122.1106580892@ocs3.ocs.com.au>
In-Reply-To: <14122.1106580892@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@sgi.com>
Cc: kdb@oss.sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Hi Keith,

> I have no hardware to test on, so I have
> to rely on HP to keep the USB patches in KDB up to date. 

Does that mean that there is USB support for KDBv4.4 for kernel 2.6 
for i386 machines? Or the patch for i386 also comes from the HP guys.

Regards
Saravanan S

On Tue, 25 Jan 2005 02:34:52 +1100, Keith Owens <kaos@sgi.com> wrote:
> On Mon, 24 Jan 2005 15:21:08 -0000,
> gowda_avinash@emc.com wrote:
> >All:
> >I tried to get Kdb working on SuSe 9 ia64 box (kernel version
> >2.6.5-7.111.19). Turns out that the keyboard/machine goes into a hang state.
> >I have a usb keyboard!
> >
> >Googling around I found that Keith had disabled the USB keyboard support
> >some time back due to changes in some APIs (kernel version
> >linux-2.6.5-SLES9_SP1_BRANCH).
> >
> >Is this something that could be a cause for my problem? Should I think about
> >upgrading my kernel to 2.6.10 (hoping that the issue's been fixed in this
> >version)?
> 
> The USB keyboard support in KDB was written by HP, because their
> systems have USB keyboards.  I have no hardware to test on, so I have
> to rely on HP to keep the USB patches in KDB up to date.  That has not
> happened recently.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
