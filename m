From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 15 Oct 2003 23:14:26 +0000
Subject: Re: GENERIC still failing?
Message-Id: <marc-linux-ia64-106625995621310@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106617635106445@msgid-missing>
In-Reply-To: <marc-linux-ia64-106617635106445@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 15, 2003 at 12:24:30PM +0100, Matthew Wilcox wrote:
> Which *config tool are you using?  make config/oldconfig/defconfig have
> a bug which Roman hasn't got round to pushing upstream yet.
> 
> This whitespace-damaged diff shows what needs to be fixed:

Thanks but that patch didn't seem to make any difference; a make
config seems to work as expected.

I'm using menuconfig; the problems I see appear two fold.

Firstly, I would have expected that when I selected 'Help' on, say,

IA-64 system type (generic)  ---> 

I would get the help text that says something like what is actually
assocated with the IA64_GENERIC option.  This seems to be an ordering
decision in the ia64 Kconfig file.

But, as that help text is associated with IA64_GENERIC, I would have
expected as I when I was in the choice and selected help for 

 (X) generic  

I would have got that big spiel  

"This selects the system type of your hardware.  A "generic" kernel
..."

If I use make config, when I select '1?' in the IA-64 system type
choice, I receive the help text associated with it.  But with make
config, I can't see a way to get help for the choice overall.

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au
