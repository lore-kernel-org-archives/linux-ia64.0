From: "Hiram Clawson, 831-427-7519" <hiramc@sco.COM>
Date: Thu, 17 Aug 2000 21:20:18 +0000
Subject: Re: [Linux-ia64] Re: [Xpert] XFree 4.0.1 module loading
Message-Id: <marc-linux-ia64-105590678205350@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Rather than trying to work with the XFree86 X server to fix up this
loading situation, it is a lot easier to create a couple of tiny
example programs that dlopen() each other to watch the interaction.

I believe you are talking about the sequence:

	main() dlopens foo0()
	foo0() and main() can freely exchange references with each other.
	Now foo0() dlopens foo1()
	The question is, which of main(), foo0() and foo1() can freely
	exchange references with each other ?  Which types of
	dynamic loading schemes will allow all loaded programs to share
	all symbols.

--Hiram

 Date: Thu, 17 Aug 2000 12:13:33 -0400 (EDT)
 From: Stuart Anderson <anderson@metrolink.com>
 To: Marc Aurele La France <tsi@gpu.srv.ualberta.ca>
 cc: Keith Owens <kaos@ocs.com.au>, Michael Madore <mmadore@turbolinux.com>, 
     Bill Nottingham <notting@redhat.com>, linux-ia64@linuxia64.org
 Subject: Re: [Linux-ia64] Re: [Xpert] XFree 4.0.1 module loading 
 
 I've received some code, and should have hardware soon, so I was planning
 on working on it.
 
 On Wed, 16 Aug 2000, Marc Aurele La France wrote:
 
 > On Fri, 11 Aug 2000, Keith Owens wrote:
 > 
 > > >> I guess my question now is:  Should the dlopen() loader be able to
 > > >> resolve inter-module dependencies?  If not, what is left to be done with
 > > >> the elf loader make it functional on IA64?
 > 
 > > >Support for the ELF64 relocation types. Just like a block of code was 
added
 > > >for Alpha support, the same type of thing will have to be added for IA64.
 > 
 > > modutils 2.3.13 has IA64 relocation support, courtesy of Mike Stephens
 > > at Intel.  obj/obj_ia64.c should be a reasonable starting point.
 > 
 > Is anyone going ahead with this?  If not, I can probably come pretty close
 > to getting it working even though I'd be going in blind (no hardware).
 > 
 > Let me know.
 > 
 > Marc.
 > 
 > +----------------------------------+-----------------------------------+
 > |  Marc Aurele La France           |  work:   1-780-492-9310           |

