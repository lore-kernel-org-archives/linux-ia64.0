From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 01 Aug 2001 13:12:18 +0000
Subject: Re: [Linux-ia64] Ksymoops
Message-Id: <marc-linux-ia64-105590693005978@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005944@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005944@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 27 Jul 2001 10:08:11 -0400, 
"peck, william" <peck_william@emc.com> wrote:
>Has anyone here used ksymoops on ia64?  I don't know if I am doing anything
>wrong but I get an awful lot of warnings when I try to run a panic through
>it on ia64.

Thanks for the test reports (off list).  It is obvious what is wrong,
/proc/ksyms does not list the address of functions, instead it lists
the address of the function pointer which contains { &function, GP }.
That breaks all the assumptions used by ksymoops and other debuggers
which rely on symbol tables.  System.map lists the real function
addresses.  By coincidence, all my ia64 ksymoops runs were done from
ix86 (cross debug mode) using just System.map, no ksyms.

I need to think about the best way of handling this.  insmod needs the
function pointer, ksymoops needs the real function address.  Ideally
ksyms should list both addresses, the pointer and the real function
address.  That will be tricky given the current EXPORT_SYMBOL()
mechanism, there is no obvious way to distinguish between functions and
other addresses, this problem only applies to functions.


