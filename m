From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Tue, 08 Jan 2002 13:23:15 +0000
Subject: [Linux-ia64] Re: can we make anonymous memory non-EXECUTABLE?
Message-Id: <marc-linux-ia64-105590698805773@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805771@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805771@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Opinions?
> 
> Quite frankly, my personal preference is "We are the borg of x86" choice,
> especially on ia64. The security issue with stack smashing etc is a
> complete non-issue: if the program allows a buffer overrun it is insecure
> whether EXEC is set or not.

I semi agree with Linus comment. However it is a lot easier to make attacks
_hard_ especially on a 64bit box by having non executable areas. My
personal feeling is that for an existing production world port like Alpha
you fix the sbrk bug so you always get executable memory. For the IA64
its a new platform and you either say "No it isnt executable" or let ld.so
and malloc do the remapping based on environment variable settings.

We are borg of x86 is true for the near future, but codifying an x86ism for
all ports for ever seems unwise.

For IA32 on IA64 binaries you would however need to keep the executable
data behaviour.

Alan

