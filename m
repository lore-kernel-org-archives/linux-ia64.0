From: "Pereira, D LailaX E" <d.lailax.e.pereira@intel.com>
Date: Wed, 28 Nov 2001 17:56:44 +0000
Subject: RE: [Linux-ia64] unaligned access?
Message-Id: <marc-linux-ia64-105590698805555@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

scp->sc_ip is not properly aligned for an unsigned long access, i.e.
it is not a multiple of 8.

Dan
But , 
sc_ip field is defined as "unsigned long" in 
struct sigcontext {
	...
	unsigned long sc_ip;
	...
}

??

d'laila 



On Wed, 28 Nov 2001, Pereira, D LailaX E wrote:

> HI 
> While running the following  code, 
> define WRITE_CAUSED_SIGBUS_or_SEGV \
>         (((*(unsigned long*)scp->sc_ip)>>21)&1)
> ....
> if (WRITE_CAUSED_SIGBUS_or_SEGV){
> ........
> }
> else {
> .........
> }
> 
> I get the following error on the "if " statement: 
> stress.udp(31438): unaligned access to
> 0x4000000000003541,ip=0x4000000000015fc1
> Please let me know what is wrong with the macro:
> define WRITE_CAUSED_SIGBUS_or_SEGV \
>         (((*(unsigned long*)scp->sc_ip)>>21)&1)


