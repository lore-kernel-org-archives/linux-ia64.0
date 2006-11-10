From: Keith Owens <kaos@sgi.com>
Date: Fri, 10 Nov 2006 06:15:57 +0000
Subject: Re: KDB blindly reads keyboard port
Message-Id: <16089.1163139357@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Thu, 09 Nov 2006 21:28:03 PDT."
             <20061110042803.GU16952@parisc-linux.org> 
References: <200609261354.30722.bjorn.helgaas@hp.com>
In-Reply-To: <200609261354.30722.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Matthew Wilcox (on Thu, 9 Nov 2006 21:28:03 -0700) wrote:
>On Fri, Nov 10, 2006 at 03:23:20PM +1100, Keith Owens wrote:
>> Bjron, could you try kdb-v4.4-2.6.19-rc5-{common,ia64}-2 on your
>> problem system?  I changed kdb so it only uses the keyboard if at least
>> one console matches the pattern /^tty[0-9]*$/.  IOW, if the user
>> specifies an i8042 style console on the command line (or uses the
>> default with CONFIG_VT=y) then kdb will attempt to use that keyboard.
>> Otherwise kdb ignores a VT style console, even when the kernel is
>> compiled with CONFIG_VT=y.
>
>If I'm using an HP Integrity system with a USB keyboard, won't I still
>have a console that matches ^tty[0-9]*$ ?

Good point.  How about the console list must include /^tty[0-9]*$/
_and_ there must be an interrupt registered with a name of "i8042"
before KDB will attempt to access i8042 ports?

