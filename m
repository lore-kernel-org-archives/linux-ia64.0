From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 11 Aug 2000 00:16:32 +0000
Subject: Re: [Linux-ia64] Re: [Xpert] XFree 4.0.1 module loading
Message-Id: <marc-linux-ia64-105590678205315@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 10 Aug 2000 12:54:16 -0400 (EDT), 
Stuart Anderson <anderson@metrolink.com> wrote:
>On Thu, 10 Aug 2000, Michael Madore wrote:
>> I guess my question now is:  Should the dlopen() loader be able to
>> resolve inter-module dependencies?  If not, what is left to be done with
>> the elf loader make it functional on IA64?
>
>Support for the ELF64 relocation types. Just like a block of code was added
>for Alpha support, the same type of thing will have to be added for IA64.

modutils 2.3.13 has IA64 relocation support, courtesy of Mike Stephens
at Intel.  obj/obj_ia64.c should be a reasonable starting point.


