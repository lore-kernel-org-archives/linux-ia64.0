From: KOCHI Takayoshi <t-kouchi@mvf.biglobe.ne.jp>
Date: Fri, 07 Sep 2001 20:12:25 +0000
Subject: Re: [Linux-ia64] AT Keyboard not present?
Message-Id: <marc-linux-ia64-105590698805144@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805137@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805137@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sorry, I didn't include the configuration of my machine.

It was a BigSur with a PS/2 keyboard and a PS/2 mouse.
I didn't configure usb driver in the kernel nor load
as a module.

On Fri, 7 Sep 2001 14:05:52 -0500
Krishnakumar B <kitty@cs.wustl.edu> wrote:

> On Friday, 7 September 2001, KOCHI Takayoshi wrote:
> > Recently I noticed
> > 
> > keyboard: Timeout - AT keyboard not present?
> 
> I guess this happens because you are using a USB keyboard and the kernel
> looks for a PS/2 keyboard. New machines from Dell ship with a USB keyboard
> by default. Till the USB modules are loaded, I see this error (once or
> twice). Once the USB modules are loaded, this message disappears. Is there
> any way to prevent this happening ? I saw that when using RedHat's kernel,
> this message doesn't show up. What do I need to suppress this message if I
> have a USB keyboard ?

Regards,
-- 
KOCHI Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


