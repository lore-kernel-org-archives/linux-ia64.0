From: Keith Owens <kaos@sgi.com>
Date: Mon, 24 Jan 2005 15:34:52 +0000
Subject: Re: Announce: kdb v4.4 is available for kernel 2.6.10
Message-Id: <14122.1106580892@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Mon, 24 Jan 2005 15:21:08 -0000."
             <50C05B7AA7D6924FB5E384EF14BC647BC451EE@inba1mx2.corp.emc.com> 
References: <12956.1085377697@kao2.melbourne.sgi.com>
In-Reply-To: <12956.1085377697@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: gowda_avinash@emc.com
Cc: kdb@oss.sgi.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Mon, 24 Jan 2005 15:21:08 -0000, 
gowda_avinash@emc.com wrote:
>All:
>I tried to get Kdb working on SuSe 9 ia64 box (kernel version
>2.6.5-7.111.19). Turns out that the keyboard/machine goes into a hang state.
>I have a usb keyboard!
>
>Googling around I found that Keith had disabled the USB keyboard support
>some time back due to changes in some APIs (kernel version
>linux-2.6.5-SLES9_SP1_BRANCH).
>
>Is this something that could be a cause for my problem? Should I think about
>upgrading my kernel to 2.6.10 (hoping that the issue's been fixed in this
>version)?

The USB keyboard support in KDB was written by HP, because their
systems have USB keyboards.  I have no hardware to test on, so I have
to rely on HP to keep the USB patches in KDB up to date.  That has not
happened recently.

