From: Andi Kleen <ak@suse.de>
Date: Wed, 21 Jan 2004 18:11:52 +0000
Subject: Re: Link error with linux-2.5 bk
Message-Id: <20040121191152.16b162b3.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040120144809.GT27591@localhost>
In-Reply-To: <20040120144809.GT27591@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 21 Jan 2004 09:57:43 -0800
"Luck, Tony" <tony.luck@intel.com> wrote:

> > Andrew sent me the attached.  He seems to agree with your analysis & fix.
> 
> Why didn't this show up on other architecture builds?  Doesn't anyone
> else discard .exit.text?  Or does everyone else have the default
> for CONFIG_DUMMY set to 'n' or 'm' rather than 'y'?

Most likely the later.

> 
> I'd also like to nominate:
> 
>  local symbol 0: discarded in section `.exit.text' from drivers/built-in.o


> for the "Least helpful error message" award(*).  From previous
> experience I know that this is caused by improper use of
> __exit ... but it would really help a lot if the message
> had an actual symbol name, rather than "local symbol 0".

It can be found using create application of objdump -Sr and nm.
I had this problem in the past too with other symbols (that is
why 2.6/i386 discards some sections at runtime, not in the linker)

-Andi
