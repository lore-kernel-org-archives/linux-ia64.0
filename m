From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 13 Jun 2001 16:35:59 +0000
Subject: Re: [Linux-ia64] modules external refs
Message-Id: <marc-linux-ia64-105590693005727@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005726@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005726@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 13 Jun 2001 17:04:51 +0200, 
gerard <gerard@mylos.grenoble.hp.com> wrote:
>I have put a printk in the second module trying to access the controler
>in which I  print the address of the function it tries to call, it
>corresponds to what
>I see in /proc/ksyms, but when I call that function, I get a
>Unimplemented Instruction Address fault .

IA64 function pointers do not point to the function, instead they point
to a descriptor area which contains data about the function, including
its real address.  If you are calling direct to the address in ksyms
then you are bypassing the function descriptor and r1 will contain an
incorrect value.  Also make sure that your modules are compiled with
the correct options, compile an existing module and copy the flags.


