From: Bill Nottingham <notting@redhat.com>
Date: Thu, 10 Aug 2000 17:59:31 +0000
Subject: Re: [Linux-ia64] Re: [Xpert] XFree 4.0.1 module loading
Message-Id: <marc-linux-ia64-105590678205313@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stuart Anderson (anderson@metrolink.com) said: 
> > I guess my question now is:  Should the dlopen() loader be able to
> > resolve inter-module dependencies?  If not, what is left to be done with
> > the elf loader make it functional on IA64?
> 
> Support for the ELF64 relocation types. Just like a block of code was added
> for Alpha support, the same type of thing will have to be added for IA64.

Exactly; the patch we have does that, it just doesn't quite work yet.
They way the loader is (please, correct me if I'm wrong) is that
it can load modules in various ways: there's an a.out module
loader, a dlopen() based loader, and an 'elfloader' that does
all the elf relocations/symbol resolution itself.

We compile the modules for use with the dlopen() based loader here
because that works for us, and we haven't worried about the
inter-module dependencies that Michael is having yet.
The elfloader patch we have is in a state where it compiles,
does the relocations, etc., but it doesn't quite work
(at least in testing here; other people may want to check if
it works for them.)  Since we were happy with how the dlopen()
based stuff worked for us, we haven't worked on fixing the
elfloader recently.

If the X people want me to post what we have, I can do that;
it's obviously hard to debug the module loader without the
actual hardware. :)  Jakub Jelinek (jakub@redhat.com) is
the one who did the actual patch.

Bill

